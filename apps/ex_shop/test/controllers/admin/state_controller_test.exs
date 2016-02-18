defmodule ExShop.Admin.StateControllerTest do
  use ExShop.ConnCase

  alias ExShop.State
  alias ExShop.Country

  @country_attrs %{"name" => "Country", "iso" => "Co", "iso3" => "Con", "numcode" => "123"}
  @state_attrs   %{"abbr" => "ST", "name" => "State"}

  test "create fails with invalid paramters" do
    country = insert_country!
    conn = post conn, admin_country_state_path(conn, :create, country), state: %{}
    assert Enum.count(json_response(conn, 422)["errors"]) > 0
  end

  test "create succeeds with valid parameters" do
    country = insert_country!
    conn = post conn, admin_country_state_path(conn, :create, country), state: @state_attrs
    assert json_response(conn, 201)["abbr"] == @state_attrs["abbr"]
  end

  test "remove the state" do
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

end
