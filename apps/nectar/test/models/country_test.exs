defmodule Nectar.CountryTest do
  use Nectar.ModelCase

  alias Nectar.Country

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

  test "validate length of iso3 code" do
    assert errors_on(%Country{}, @invalid_attrs)[:iso3] == {"should be %{count} character(s)", [count: 3]}
  end

  test "validate length of iso code" do
    assert errors_on(%Country{}, @invalid_attrs)[:iso] == {"should be %{count} character(s)", [count: 2]}
  end

  # HACK: the order of unique constraint validations depend upon the order in which these indexes are defined.
  test "prevent reuse of iso" do
    insert_country_with_valid_attrs!
    {status, changeset} = Country.changeset(%Country{}, @valid_attrs) |> Repo.insert
    assert status == :error
    assert changeset.errors[:iso] == "has already been taken"
  end

  test "prevent reuse of iso3" do
    insert_country_with_valid_attrs!
    {status, changeset} = Country.changeset(%Country{}, Dict.merge(@valid_attrs, %{"iso" => "NK"})) |> Repo.insert
    assert status == :error
    assert changeset.errors[:iso3] == "has already been taken"
  end

  test "prevent reuse of name" do
    insert_country_with_valid_attrs!
    {status, changeset} = Country.changeset(%Country{}, Dict.merge(@valid_attrs, %{"iso" => "NK", "iso3" => "NKE"})) |> Repo.insert
    assert status == :error
    assert changeset.errors[:name] == "has already been taken"
  end

  test "prevent reuse of numcode" do
    insert_country_with_valid_attrs!
    {status, changeset} = Country.changeset(%Country{}, Dict.merge(@valid_attrs, %{"iso" => "NK", "iso3" => "NKE", "name" => "Junk"})) |> Repo.insert
    assert status == :error
    assert changeset.errors[:numcode] == "has already been taken"
  end

  # Helper methods
  defp insert_country_with_valid_attrs! do
    Country.changeset(%Country{}, @valid_attrs)
    |> Repo.insert!
  end

end
