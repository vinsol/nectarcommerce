defmodule Nectar.Admin.ZoneMemberControllerTest do
  use Nectar.ConnCase

  alias Nectar.Repo
  alias Nectar.Country
  alias Nectar.Zone
  alias Nectar.User

  setup(context) do
    do_setup(context)
  end

  test "adds a zone member with missing zoneable id", %{conn: conn} do
    zone = Nectar.TestSetup.Zone.create!
    conn = post conn, admin_zone_zone_member_path(conn, :create, zone), zone_member: %{}
    assert conn.halted
  end

  test "adds a zone member and returns zoneable id", %{conn: conn} do
    zone = Nectar.TestSetup.Zone.create!
    zone_member_attrs = Nectar.TestSetup.ZoneMember.attrs_with_country
    conn = post conn, admin_zone_zone_member_path(conn, :create, zone), zone_member: zone_member_attrs
    assert json_response(conn, 201)["zoneable_id"] == zone_member_attrs[:zoneable_id]
  end


  test "removes a zone member", %{conn: conn} do
    zone = Nectar.TestSetup.Zone.create!
    zone_member_attrs = Nectar.TestSetup.ZoneMember.attrs_with_country
    zone_member_id = zone_member_attrs |> Map.get(:zoneable_id)

    # create the zone
    post conn, admin_zone_zone_member_path(conn, :create, zone), zone_member: zone_member_attrs
    zone_member_initial_count = Enum.count (Nectar.Query.Zone.members(Repo, zone))

    [zone_member] = Nectar.Query.Zone.members(Repo, zone)

    # delete the zone
    delete_conn = delete conn, admin_zone_zone_member_path(conn, :delete, zone, zone_member)
    zone_member_updated_count = Enum.count (Nectar.Query.Zone.members(Repo, zone))

    assert zone_member_initial_count - zone_member_updated_count == 1
    assert json_response(delete_conn, 200)["id"] == zone_member_id
  end

  defp do_setup(%{nologin: _} = _context) do
    {:ok, %{conn: conn}}
  end

  defp do_setup(_context) do
    {:ok, admin_user} = Nectar.TestSetup.User.create_admin
    conn = guardian_login(admin_user)
    {:ok, %{conn: conn}}
  end
end
