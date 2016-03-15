defmodule Nectar.AddressTest do
  use Nectar.ModelCase

  @valid_attrs %{address_line_1: "address line", address_line_2: "address line 2"}
  @invalid_attrs %{address_line_1: "ad", address_line_2: "add"}

  alias Nectar.Address
  alias Nectar.State
  alias Nectar.Country

  test "validates length of address line 1" do
    errors = errors_on(%Address{}, @invalid_attrs)
    assert Dict.keys(errors) -- [:address_line_1, :address_line_2, :country_id, :state_id] == []
    assert errors[:address_line_1] == {"should be at least %{count} character(s)", [count: 10]}
  end

  test "validates length of address line 2" do
    errors = errors_on(%Address{}, @invalid_attrs)
    assert Dict.keys(errors) -- [:address_line_1, :address_line_2, :country_id, :state_id] == []
    assert errors[:address_line_2] == {"should be at least %{count} character(s)", [count: 10]}
  end

  test "changeset is valid" do
    changeset = Address.changeset(%Address{}, Map.merge(@valid_attrs, invalid_country_and_state_ids))
    assert changeset.valid?
  end

  test "insert fails when country id and state id not present in db" do
    changeset = Address.changeset(%Address{}, Map.merge(@valid_attrs, invalid_country_and_state_ids))
    assert changeset.valid?
    {status, updated_changeset} = Repo.insert changeset
    assert status == :error
    refute updated_changeset.valid?
    assert updated_changeset.errors[:state_id] == "does not exist"
  end

  test "insert succeeds when country id and state id present in db" do
    changeset = Address.changeset(%Address{}, Map.merge(@valid_attrs, valid_country_and_state_ids))
    assert changeset.valid?
    {status, _} = Repo.insert changeset
    assert status == :ok
  end


  # Helper methods
  defp invalid_country_and_state_ids do
    %{country_id: -1, state_id: -1}
  end

  defp valid_country_and_state_ids do
    country =
      Country.changeset(%Country{}, %{"name" => "Country", "iso" => "Co",
                                    "iso3" => "Con", "numcode" => "123"})
      |> Repo.insert!
    state =
      State.changeset(%State{}, %{"name" => "State", "abbr" => "ST", "country_id" => country.id})
      |> Repo.insert!
    %{country_id: country.id, state_id: state.id}
  end

end
