defmodule Nectar.Admin.ZoneControllerTest do
  use Nectar.ConnCase

  alias Nectar.Repo
  alias Nectar.Zone
  alias Nectar.User

  @valid_attrs   %{name: "NA", description: "TEST", type: "Country"}
  @invalid_attrs %{name: "NA", description: "FAIL TEST", type: "DoesNotExist"}

  setup(context) do
    do_setup(context)
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, admin_zone_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing Zones"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, admin_zone_path(conn, :new)
    assert html_response(conn, 200) =~ "Create Zone"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, admin_zone_path(conn, :create), zone: @valid_attrs
    assert redirected_to(conn) == admin_zone_path(conn, :index)
    assert Repo.get_by(Zone, @valid_attrs)
  end

  @tag :pending
  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, admin_zone_path(conn, :create), zone: @invalid_attrs
    assert html_response(conn, 200) =~ "Create Zone"
    # Please confirm whether right way
    #assert html_response(conn, 200) =~ "Not Country"
    assert html_response(conn, 200) =~ "is invalid"
  end

  test "shows chosen resource", %{conn: conn} do
    zone = Repo.insert! Zone.changeset(%Zone{}, @valid_attrs)
    conn = get conn, admin_zone_path(conn, :show, zone)
    assert html_response(conn, 200) =~ @valid_attrs[:name]
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, admin_zone_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    zone = Repo.insert! %Zone{}
    conn = get conn, admin_zone_path(conn, :edit, zone)
    assert html_response(conn, 200) =~ "Edit Zone"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    zone = Repo.insert! %Zone{}
    conn = put conn, admin_zone_path(conn, :update, zone), zone: @valid_attrs
    assert redirected_to(conn) == admin_zone_path(conn, :show, zone)
    assert Repo.get_by(Zone, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    zone = Repo.insert! %Zone{}
    conn = put conn, admin_zone_path(conn, :update, zone), zone: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit Zone"
  end

  test "deletes chosen resource", %{conn: conn} do
    zone = Repo.insert! %Zone{}
    conn = delete conn, admin_zone_path(conn, :delete, zone)
    assert redirected_to(conn) == admin_zone_path(conn, :index)
    refute Repo.get(Zone, zone.id)
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
