defmodule Nectar.Admin.CountryControllerTest do
  use Nectar.ConnCase

  alias Nectar.Repo
  alias Nectar.Country
  alias Nectar.User

  @valid_attrs   %{name: "CountryName", iso: "Co", iso3: "Con", numcode: "123"}
  @invalid_attrs %{name: "Country", iso: "C", iso3: "Co", numcode: "123"}

  setup(context) do
    do_setup(context)
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, admin_country_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing countries"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, admin_country_path(conn, :new)
    assert html_response(conn, 200) =~ "New country"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, admin_country_path(conn, :create), country: @valid_attrs
    assert redirected_to(conn) == admin_country_path(conn, :index)
    assert Repo.get_by(Country, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, admin_country_path(conn, :create), country: @invalid_attrs
    assert html_response(conn, 200) =~ "New country"
  end

  test "shows chosen resource", %{conn: conn} do
    country = Repo.insert! Country.changeset(%Country{}, @valid_attrs)
    conn = get conn, admin_country_path(conn, :show, country)
    assert html_response(conn, 200) =~ @valid_attrs[:name]
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, admin_country_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    country = Repo.insert! %Country{}
    conn = get conn, admin_country_path(conn, :edit, country)
    assert html_response(conn, 200) =~ "Edit country"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    country = Repo.insert! %Country{}
    conn = put conn, admin_country_path(conn, :update, country), country: @valid_attrs
    assert redirected_to(conn) == admin_country_path(conn, :show, country)
    assert Repo.get_by(Country, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    country = Repo.insert! %Country{}
    conn = put conn, admin_country_path(conn, :update, country), country: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit country"
  end

  test "deletes chosen resource", %{conn: conn} do
    country = Repo.insert! %Country{}
    conn = delete conn, admin_country_path(conn, :delete, country)
    assert redirected_to(conn) == admin_country_path(conn, :index)
    refute Repo.get(Country, country.id)
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
