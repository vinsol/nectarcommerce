defmodule ExShop.StateTest do
  use ExShop.ModelCase

  alias ExShop.Country
  alias ExShop.State

  # need to add country id
  @valid_attrs %{"name" => "State", "abbr" =>  "ST"}

  test "changeset with valid attributes" do
    changeset = State.changeset(%State{}, state_attrs)
    assert changeset.valid?
  end

  test "save with valid attributes" do
    {status, state} = State.changeset(%State{}, state_attrs)
    |> Repo.insert
    assert status == :ok
  end

  defp state_attrs do
    Map.merge(@valid_attrs, %{"country_id" => create_country.id})
  end

  defp create_country do
    Country.changeset(%Country{}, %{"name" => "Country", "iso" => "Co",
                                    "iso3" => "Con", "numcode" => "123"})
    |> Repo.insert!
  end

end
