defmodule Nectar.CountryTest do
  use Nectar.ModelCase

  alias Nectar.Country
  alias Nectar.TestSetup

  describe "fields" do
    has_fields Country, ~w(id name iso iso3 iso_name numcode has_states)a ++ timestamps
  end

  describe "associations" do
    has_associations Country, ~w(states zone_members zones)a
  end

  describe "validations" do
    test "changeset with valid attributes" do
      changeset = Country.changeset(%Country{}, TestSetup.Country.valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = Country.changeset(%Country{}, TestSetup.Country.invalid_attrs)
      refute changeset.valid?
    end

    test "validate length of iso3 code" do
      attrs = TestSetup.Country.invalid_attrs |> Map.merge(%{iso3: "ar"})
      assert errors_on(%Country{}, attrs)[:iso3] == "should be 3 character(s)"
    end

    test "validate length of iso code" do
      attrs = TestSetup.Country.invalid_attrs |> Map.merge(%{iso: "a"})
      assert errors_on(%Country{}, attrs)[:iso] == "should be 2 character(s)"
    end
  end

  describe "changeset/2" do
    test "generates iso name by upcasing the country name" do
      changeset = Country.changeset(%Country{}, TestSetup.Country.valid_attrs)
      assert changeset.changes[:iso_name] == String.upcase(TestSetup.Country.valid_attrs["name"])
    end
  end

  describe "db validations" do
    # Params are rewritten because postgres fails on the first validation
    test "prevent reuse of iso" do
      TestSetup.Country.create_country!
      {status, changeset} = TestSetup.Country.create_country(TestSetup.Country.valid_attrs)
      assert status == :error
      assert errors_on(changeset)[:iso] == "has already been taken"
    end

    test "prevent reuse of iso3" do
      TestSetup.Country.create_country!
      attrs = Dict.merge(TestSetup.Country.valid_attrs, %{"iso" => "NK"})
      {status, changeset} = TestSetup.Country.create_country(attrs)
      assert status == :error
      assert errors_on(changeset)[:iso3] == "has already been taken"
    end

    test "prevent reuse of name" do
      TestSetup.Country.create_country!
      attrs = Dict.merge(TestSetup.Country.valid_attrs, %{"iso" => "NK", "iso3" => "NKE"})
      {status, changeset} = TestSetup.Country.create_country(attrs)
      assert status == :error
      assert errors_on(changeset)[:name] == "has already been taken"
    end

    test "prevent reuse of numcode" do
      TestSetup.Country.create_country!
      attrs = Dict.merge(TestSetup.Country.valid_attrs, %{"iso" => "NK", "iso3" => "NKE", "name" => "Junk"})
      {status, changeset} = TestSetup.Country.create_country(attrs)
      assert status == :error
      assert errors_on(changeset)[:numcode] == "has already been taken"
    end
  end

end
