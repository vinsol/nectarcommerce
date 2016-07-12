defmodule Nectar.Command.AddressTest do
  use Nectar.ModelCase
  alias Nectar.Address
  alias Nectar.TestSetup

  describe "insert db validations" do
    test "insert fails when country id and state id not present in db" do
      changeset = Address.changeset(%Address{}, TestSetup.Address.valid_attrs)
      assert changeset.valid?
      {status, updated_changeset} = Nectar.Command.Address.insert(Nectar.Repo, TestSetup.Address.valid_attrs)
      assert status == :error
      refute updated_changeset.valid?
      assert updated_changeset.errors[:state_id] == {"does not exist", []}
    end

    test "insert succeeds when country id and state id present in db" do
      {status, _} = Nectar.Command.Address.insert(Nectar.Repo, TestSetup.Address.valid_attrs_with_country_and_state!)
      assert status == :ok
      assert Enum.count(Nectar.Query.Address.all(Nectar.Repo)) == 1
    end
  end
end
