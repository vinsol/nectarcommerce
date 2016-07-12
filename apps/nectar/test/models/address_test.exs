defmodule Nectar.AddressTest do
  use Nectar.ModelCase
  alias Nectar.Address
  alias Nectar.TestSetup

  describe "fields" do
    has_fields Address, ~w(id address_line_1 address_line_2 state_id country_id)a ++ timestamps
  end

  describe "associations" do
    assocs =
      ~w(user_address user order_billing_addresses billing_orders)a ++
      ~w(order_shipping_addresses shipping_order state country)a

    has_associations Address, assocs
  end

  describe "validations" do
    test "validates length of address line 1" do
      errors = errors_on(%Address{}, TestSetup.Address.invalid_attrs)
      assert errors[:address_line_1] == "should be at least 10 character(s)"
    end

    test "validates length of address line 2" do
      errors = errors_on(%Address{}, TestSetup.Address.invalid_attrs)
      assert errors[:address_line_2] == "should be at least 10 character(s)"
    end

    test "changeset is valid" do
      changeset = Address.changeset(%Address{}, TestSetup.Address.valid_attrs)
      assert changeset.valid?
    end

    test "changeset is not valid" do
      changeset = Address.changeset(%Address{}, TestSetup.Address.invalid_attrs)
      refute changeset.valid?
    end
  end

  describe "db validations" do
    test "insert fails when country id and state id not present in db" do
      changeset = Address.changeset(%Address{}, TestSetup.Address.valid_attrs)
      assert changeset.valid?
      {status, updated_changeset} = Repo.insert changeset
      assert status == :error
      refute updated_changeset.valid?
      assert updated_changeset.errors[:state_id] == {"does not exist", []}
    end

    test "insert succeeds when country id and state id present in db" do
      changeset = Address.changeset(%Address{}, TestSetup.Address.valid_attrs_with_country_and_state!)
      assert changeset.valid?
      {status, _} = Repo.insert changeset
      assert status == :ok
      assert Enum.count(Repo.all(Address))  == 1
    end
  end

end
