defmodule Nectar.Admin.StateControllerTest do
  use Nectar.ConnCase

  @country_attrs %{"name" => "Country", "iso" => "Co", "iso3" => "Con", "numcode" => "123"}
  @state_attrs   %{"abbr" => "ST", "name" => "State"}

  setup(context) do
    do_setup(context)
  end

  test "create fails with invalid paramters", %{conn: conn} do
    country = Nectar.TestSetup.Country.create_country!
    conn = post conn, admin_country_state_path(conn, :create, country), state: %{}
    assert Enum.count(json_response(conn, 422)["errors"]) > 0
  end

  test "create succeeds with valid parameters", %{conn: conn} do
    country = Nectar.TestSetup.Country.create_country!
    conn = post conn, admin_country_state_path(conn, :create, country), state: @state_attrs
    assert json_response(conn, 201)["abbr"] == @state_attrs["abbr"]
  end

  test "remove the state", %{conn: conn} do
    country = Nectar.TestSetup.Country.create_country!
    state = Nectar.TestSetup.State.create_state(country)
    delete_conn = delete conn, admin_country_state_path(conn, :delete, country, state)
    assert is_nil json_response(delete_conn, 204)
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
