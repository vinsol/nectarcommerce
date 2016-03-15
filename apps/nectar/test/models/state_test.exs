defmodule Nectar.StateTest do
  use Nectar.ModelCase

  alias Nectar.Country
  alias Nectar.State

  # need to add country id
  @valid_partial_state_attrs %{"name" => "State", "abbr" =>  "ST"}

  test "changeset with valid attributes" do
    changeset = State.changeset(%State{}, state_attrs)
    assert changeset.valid?
  end

  test "save with valid attributes" do
    {status, _state} = State.changeset(%State{}, state_attrs) |> Repo.insert
    assert status == :ok
  end

  test "missing country_id makes changeset invalid" do
    {status, changeset} = State.changeset(%State{}, @valid_partial_state_attrs) |> Repo.insert
    assert status == :error
    refute changeset.valid?
    assert [country_id: "can't be blank"] == changeset.errors
  end

  defp state_attrs do
    Map.merge(@valid_partial_state_attrs, %{"country_id" => create_country.id})
  end

  defp create_country do
    Country.changeset(%Country{}, %{"name" => "Country", "iso" => "Co",
                                    "iso3" => "Con", "numcode" => "123"})
    |> Repo.insert!
  end

end
