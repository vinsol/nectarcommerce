defmodule Nectar.Admin.ZoneMemberController do
  use Nectar.Web, :admin_controller

  alias Nectar.ZoneMember
  alias Nectar.Zone

  plug :scrub_params, "zone_member" when action in [:create]
  plug :load_zone
  plug :load_zoneable when action in [:create]

  # Add zone member
  def create(conn, %{"zone_member" => _zone_member_params}) do
    zoneable = conn.assigns[:zoneable]
    zone = conn.assigns[:zone]
     case Nectar.Command.ZoneMember.insert_for_zone(Repo, zoneable, zone) do
      {:ok, zone_member} ->
        conn
        |> put_status(201)
        |> render("zone_member.json", [zone_member: zone_member, zoneable: zoneable])
      {:error, changeset} ->
        conn
        |> put_status(422)
        |> json(%{errors: changeset.errors})
    end
  end

  # return the zoneable to add back to the menu.
  def delete(conn, %{"id" => id}) do
    zone     = conn.assigns[:zone]
    member   = Nectar.Query.Zone.member_with_id(Repo, zone, id)
    zoneable = Nectar.Query.Zone.zoneable!(Repo, conn.assigns[:zone], member.zoneable_id)
    Nectar.Command.ZoneMember.delete!(Repo, member)

    conn
    |> put_status(200)
    |> render("zoneable.json", zoneable: zoneable)
  end

  defp load_zone(conn, _params) do
    zone_id = conn.params["zone_id"]
    assign(conn, :zone, Repo.get!(Zone, zone_id))
  end

  defp load_zoneable(conn, _params) do
    zoneable_id = conn.params["zone_member"]["zoneable_id"]
    if zoneable_id do
      zoneable =  Nectar.Query.Zone.zoneable!(Repo, conn.assigns[:zone], zoneable_id)
      assign(conn, :zoneable, zoneable)
    else
      conn
      |> halt
    end
  end
end
