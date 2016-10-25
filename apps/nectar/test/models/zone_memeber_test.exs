defmodule Nectar.ZoneMemberTest do
  alias Nectar.ZoneMember
  use Nectar.ModelCase

  describe "changeset/2" do
    setup context do
      changeset = ZoneMember.changeset(%ZoneMember{}, context[:params] || %{})
      {:ok, changeset: changeset}
    end

    test "zoneable_id can't be blank", %{changeset: changeset} do
      assert errors_on(changeset)[:zoneable_id] == "can't be blank"
    end

    test "zone_id can't be blank", %{changeset: changeset} do
      assert errors_on(changeset)[:zone_id] == "can't be blank"
    end
  end

  describe "fields" do
    has_fields ZoneMember, ~w(id zoneable_id zone_id)a ++ timestamps
  end

  describe "associations" do
    has_associations ZoneMember, ~w(zone)a

    belongs_to? ZoneMember, :zone, via: Nectar.Zone
  end

end
