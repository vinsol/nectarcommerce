defmodule Nectar.Admin.ZoneMemberControllerTest do
  use Nectar.ConnCase

  alias Nectar.Repo
  alias Nectar.Country
  alias Nectar.Zone
  alias Nectar.User

  @country_attrs %{"name" => "Country", "iso" => "Co", "iso3" => "Con", "numcode" => "123"}
  @zone_attrs    %{name: "NA", description: "TEST", type: "Country"}

  setup(context) do
    do_setup(context)
  end

  test "adds a zone member with missing zoneable id", %{conn: conn} do
    zone = create_zone!
    conn = post conn, admin_zone_zone_member_path(conn, :create, zone), zone_member: %{}
    assert conn.halted
  end

  test "adds a zone member and returns zoneable id", %{conn: conn} do
    zone = create_zone!
    zone_member_attrs = zone_member_valid_attrs
    conn = post conn, admin_zone_zone_member_path(conn, :create, zone), zone_member: zone_member_attrs
    assert json_response(conn, 201)["zoneable_id"] == zone_member_attrs["zoneable_id"]
  end


  test "removes a zone member", %{conn: conn} do
    zone = create_zone!
    zone_member_attrs = zone_member_valid_attrs
    zone_member_id = zone_member_attrs |> Map.get("zoneable_id")

    # create the zone
    post conn, admin_zone_zone_member_path(conn, :create, zone), zone_member: zone_member_attrs
    zone_member_initial_count = Repo.one(from z in Zone.members(zone), select: count(z.id))

    zone_member = Repo.one(from z in Zone.members(zone), where: z.zoneable_id == ^zone_member_id)
    # delete the zone
    delete_conn = delete conn, admin_zone_zone_member_path(conn, :delete, zone, zone_member)
    zone_member_updated_count = Repo.one(from z in Zone.members(zone), select: count(z.id))

    assert json_response(delete_conn, 200)["id"] == zone_member_id
    assert zone_member_initial_count - zone_member_updated_count == 1
  end

  defp insert_country! do
    Country.changeset(%Country{}, @country_attrs)
    |> Repo.insert!
  end

  defp create_zone! do
    Zone.changeset(%Zone{}, @zone_attrs)
    |> Repo.insert!
  end

  defp zone_member_valid_attrs do
    %{
      "zoneable_id" => insert_country!.id
    }
  end

  defp do_setup(%{nologin: _} = _context) do
    {:ok, %{conn: conn}}
  end

  defp do_setup(_context) do
    admin_user = Repo.insert!(%User{name: "Admin", email: "admin@vinsol.com", encrypted_password: Comeonin.Bcrypt.hashpwsalt("vinsol"), is_admin: true})
    conn = guardian_login(admin_user, :token, key: :admin)
    {:ok, %{conn: conn}}
  end
end
