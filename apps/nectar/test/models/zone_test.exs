defmodule Nectar.ZoneTest do
  use Nectar.ModelCase
  alias Nectar.Zone

  describe "fields" do
    has_fields Zone, ~w(id name description type)a ++ timestamps
  end
  describe "associations" do
    has_associations Zone, ~w(country_zone_members state_zone_members)a

    has_many? Zone, :country_zone_members, via: Nectar.ZoneMember
    has_many? Zone, :state_zone_members, via: Nectar.ZoneMember
  end

  describe "changeset/2" do
    setup context do
      changeset = Zone.changeset(%Zone{}, context[:params] || %{})
      {:ok, changeset: changeset}
    end

    test "name can't be blank", %{changeset: changeset} do
      assert errors_on(changeset)[:name] == "can't be blank"
    end

    test "description can't be blank", %{changeset: changeset} do
      assert errors_on(changeset)[:description] == "can't be blank"
    end

    test "type can't be blank", %{changeset: changeset} do
      assert errors_on(changeset)[:type] == "can't be blank"
    end

    @tag params: %{type: "NotCountry"}
    test "type should be either Country or State", %{changeset: changeset} do
      assert errors_on(changeset)[:type] == "is invalid"
    end
  end
end
