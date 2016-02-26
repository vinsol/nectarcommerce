defmodule ExShop.Admin.StateControllerTest do
  use ExShop.ConnCase

  alias ExShop.Repo
  alias ExShop.State
  alias ExShop.Country
  alias ExShop.User

  @country_attrs %{"name" => "Country", "iso" => "Co", "iso3" => "Con", "numcode" => "123"}
  @state_attrs   %{"abbr" => "ST", "name" => "State"}

  setup(context) do
    do_setup(context)
  end

  test "create fails with invalid paramters", %{conn: conn} do
    country = insert_country!
    conn = post conn, admin_country_state_path(conn, :create, country), state: %{}
    assert Enum.count(json_response(conn, 422)["errors"]) > 0
  end

  test "create succeeds with valid parameters", %{conn: conn} do
    country = insert_country!
    conn = post conn, admin_country_state_path(conn, :create, country), state: @state_attrs
    assert json_response(conn, 201)["abbr"] == @state_attrs["abbr"]
  end

  test "remove the state", %{conn: conn} do
    country = insert_country!
    state =
      State.changeset(%State{}, Map.merge(@state_attrs, %{"country_id" => country.id}))
      |> Repo.insert!
    delete_conn = delete conn, admin_country_state_path(conn, :delete, country, state)
    assert is_nil json_response(delete_conn, 204)
  end

  defp insert_country! do
    Country.changeset(%Country{}, @country_attrs)
    |> Repo.insert!
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
