defmodule ExShop.CountryTest do
  use ExShop.ModelCase

  alias ExShop.Country

  @valid_attrs   %{"name" => "Country", "iso" => "Co", "iso3" => "Con", "numcode" => "123"}
  @invalid_attrs %{"name" => "Country", "iso" => "C", "iso3" => "Co", "numcode" => "123"}

  test "changeset with valid attributes" do
    changeset = Country.changeset(%Country{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Country.changeset(%Country{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "generates iso name by upcasing the country name" do
    changeset = Country.changeset(%Country{}, @valid_attrs)
    assert changeset.changes[:iso_name] == String.upcase(@valid_attrs["name"])
  end

  test "validate length of iso3 codes" do
    assert errors_on(%Country{}, @invalid_attrs)[:iso3] == {"should be %{count} character(s)", [count: 3]}
  end

  test "validate length of iso codes" do
    assert errors_on(%Country{}, @invalid_attrs)[:iso] == {"should be %{count} character(s)", [count: 2]}
  end

  # Helper methods
  defp insert_country_with_valid_attrs! do
    Country.changeset(%Country{}, @valid_attrs)
    |> Repo.insert!
  end

end
