defmodule ExShop.Admin.ZoneMemberControllerTest do
  use ExShop.ConnCase

  alias ExShop.Country
  alias ExShop.Zone
  alias ExShop.ZoneMember

  @country_attrs %{"name" => "Country", "iso" => "Co", "iso3" => "Con", "numcode" => "123"}
  @zone_attrs    %{name: "NA", description: "TEST", type: "Country"}


  test "adds a zone member with missing zoneable id" do
    zone = create_zone!
    conn = post conn, admin_zone_zone_member_path(conn, :create, zone), zone_member: %{}
    assert conn.halted
  end

  test "adds a zone member and returns zoneable id" do
    zone = create_zone!
    zone_member_attrs = zone_member_valid_attrs
    conn = post conn, admin_zone_zone_member_path(conn, :create, zone), zone_member: zone_member_attrs
    assert json_response(conn, 201)["id"] == zone_member_attrs["zoneable_id"]
  end


  test "removes a zone member" do
    zone = create_zone!
    zone_member_attrs = zone_member_valid_attrs
    zone_member_id = zone_member_attrs |> Map.get("zoneable_id")
    zone_member = Repo.get! Country, zone_member_id

    # create the zone
    create_conn = post conn, admin_zone_zone_member_path(conn, :create, zone), zone_member: zone_member_attrs
    zone_member_initial_count = Repo.one(from z in Zone.members(zone), select: count(z.id))

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

end
