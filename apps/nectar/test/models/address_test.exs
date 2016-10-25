defmodule Nectar.AddressTest do
  use Nectar.ModelCase, async: true
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

    belongs_to? Address, :state,                    via:     Nectar.State
    belongs_to? Address, :country,                  via:     Nectar.Country
    has_one?    Address, :user_address,             via:     Nectar.UserAddress
    has_one?    Address, :user,                     through: [:user_address,:user]
    has_many?   Address, :order_billing_addresses,  via:     Nectar.OrderBillingAddress
    has_many?   Address, :billing_orders,           through: [:order_billing_addresses,:order]
    has_many?   Address, :order_shipping_addresses, via:     Nectar.OrderShippingAddress
    has_many?   Address, :shipping_order,           through: [:order_shipping_addresses,:order]
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
end
