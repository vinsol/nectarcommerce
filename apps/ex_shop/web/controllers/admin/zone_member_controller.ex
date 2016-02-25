defmodule ExShop.Admin.ZoneMemberController do
  use ExShop.Web, :admin_controller

  alias ExShop.ZoneMember
  alias ExShop.Zone

  plug Guardian.Plug.EnsureAuthenticated, handler: ExShop.Auth.HandleUnauthenticated, key: :admin

  plug :scrub_params, "zone_member" when action in [:create]
  plug :load_zone
  plug :load_zoneable when action in [:create]

  # Add zone member
  def create(conn, %{"zone_member" => zone_member_params}) do
    zoneable = conn.assigns[:zoneable]
    zone = conn.assigns[:zone]
    changeset = ZoneMember.changeset(zoneable, zone, zone_member_params)
    case Repo.insert(changeset) do
      {:ok, _zone_member} ->
        conn
        |> put_status(201)
        |> render("zone_member.json", zoneable: zoneable)
      {:error, changeset} ->
        conn
        |> put_status(422)
        |> json(%{errors: changeset.errors})
    end
  end

  # Note: *the id here is the id of the country itself not the zone_member id*
  # TODO: figure out a better technique for handling this.
  def delete(conn, %{"id" => id}) do
    zone = conn.assigns[:zone]
    member = Zone.zoneable_member(zone, id)
    zoneable = Zone.zoneable(zone, id)
    Repo.delete!(member)
    conn
    |> put_status(200)
    |> render("zone_member.json", zoneable: zoneable)
  end

  defp load_zone(conn, _params) do
    zone_id = conn.params["zone_id"]
    assign(conn, :zone, Repo.get!(Zone, zone_id))
  end

  defp load_zoneable(conn, _params) do
    zoneable_id = conn.params["zone_member"]["zoneable_id"]
    if zoneable_id do
      zoneable = conn.assigns[:zone] |> Zone.zoneable(zoneable_id)
      assign(conn, :zoneable, zoneable)
    else
      conn
      |> halt
    end
  end
end
