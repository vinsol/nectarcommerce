defmodule Nectar.Command.CountryTest do
  use Nectar.ModelCase
  alias Nectar.Repo
  alias Nectar.TestSetup

  describe "db validations" do
    # Params are rewritten because postgres fails on the first validation
    test "prevent reuse of iso" do
      TestSetup.Country.create_country!
      {status, changeset} = Nectar.Command.Country.insert(Repo, TestSetup.Country.valid_attrs)
      assert status == :error
      assert errors_on(changeset)[:iso] == "has already been taken"
    end

    test "prevent reuse of iso3" do
      TestSetup.Country.create_country!
      attrs = Dict.merge(TestSetup.Country.valid_attrs, %{"iso" => "NK"})
      {status, changeset} = Nectar.Command.Country.insert(Repo, attrs)
      assert status == :error
      assert errors_on(changeset)[:iso3] == "has already been taken"
    end

    test "prevent reuse of name" do
      TestSetup.Country.create_country!
      attrs = Dict.merge(TestSetup.Country.valid_attrs, %{"iso" => "NK", "iso3" => "NKE"})
      {status, changeset} = Nectar.Command.Country.insert(Repo, attrs)
      assert status == :error
      assert errors_on(changeset)[:name] == "has already been taken"
    end

    test "prevent reuse of numcode" do
      TestSetup.Country.create_country!
      attrs = Dict.merge(TestSetup.Country.valid_attrs, %{"iso" => "NK", "iso3" => "NKE", "name" => "Junk"})
      {status, changeset} = Nectar.Command.Country.insert(Repo, attrs)
      assert status == :error
      assert errors_on(changeset)[:numcode] == "has already been taken"
    end
  end
end
