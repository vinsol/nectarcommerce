defmodule Nectar.AdjustmentTest do
  use Nectar.ModelCase
  alias Nectar.Adjustment
  alias Nectar.TestSetup

  describe "fields" do
    has_fields Adjustment, ~w(id shipment_id tax_id order_id amount)a ++ timestamps
  end

  describe "associations" do
    has_associations Adjustmwent, ~w(shipment tax order)a

    belongs_to? Adjustment, :shipment, via: Nectar.Shipment
    belongs_to? Adjustment, :tax,      via: Nectar.Tax
    belongs_to? Adjustment, :order,    via: Nectar.Order
  end

  describe "validations" do

    test "changeset is valid" do
      changeset = Adjustment.changeset(%Adjustment{}, TestSetup.Adjustment.valid_attrs)
      assert changeset.valid?
    end

    test "changeset is not valid" do
      changeset = Adjustment.changeset(%Adjustment{}, TestSetup.Adjustment.invalid_attrs)
      refute changeset.valid?
    end

  end
end
