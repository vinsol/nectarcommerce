defmodule Nectar.LineItemTest do
  use Nectar.ModelCase

  alias Nectar.Repo
  alias Nectar.LineItem
  alias Nectar.Order
  alias Nectar.Variant
  alias Nectar.TestSetup

  @tag :pending
  test "LineItem Mgmt with variants and not only master variant" do
    assert false
  end

  describe "fields" do
    fields =
      ~w(id variant_id order_id shipment_unit_id unit_price quantity)a ++
      ~w(total fullfilled)a ++
      timestamps
    has_fields LineItem, fields
  end

  describe "associations" do
    has_associations LineItem, ~w(variant order shipment_unit)a
  end

  describe "changeset" do
    test "line item with negative quantity" do
      product = TestSetup.Product.create_product
      master = product.master
      changeset =
        TestSetup.LineItem.line_item_changeset_with_variant(master)
        |> TestSetup.LineItem.set_quantity(-1)

      refute changeset.valid?
      assert errors_on(changeset)[:add_quantity] == "must be greater than 0"
    end

    test "line item with 0 quantity" do
      product = TestSetup.Product.create_product
      master = product.master
      changeset =
        TestSetup.LineItem.line_item_changeset_with_variant(master)
        |> TestSetup.LineItem.set_quantity(0)

      refute changeset.valid?
      assert errors_on(changeset)[:add_quantity] == "must be greater than 0"
    end


    test "adding product calculates total" do
      product = TestSetup.Product.create_product
      master = product.master
      changeset =
        TestSetup.LineItem.line_item_changeset_with_variant(master)
        |> TestSetup.LineItem.set_quantity(2)

      assert changeset.changes[:total] == Decimal.mult(Decimal.new(2), master.cost_price)
    end

    test "adding product with updated price calculates total based on the existing price" do
      product = TestSetup.Product.create_product
      master = product.master
      original_changeset =
        TestSetup.LineItem.line_item_changeset_with_variant(master)
        |> TestSetup.LineItem.set_quantity(2)

      total = original_changeset.changes[:total]
      assert total == Decimal.mult(Decimal.new(2), master.cost_price)

      new_cost_price = Decimal.mult(Decimal.new(2), master.cost_price)

      Repo.update! Variant.update_master_changeset(master, product, %{cost_price: new_cost_price, discontinue_on: Ecto.Date.utc})

      updated_changeset = LineItem.quantity_changeset(original_changeset, %{add_quantity: 1, unit_price: new_cost_price})
      assert updated_changeset.valid?
      refute total == updated_changeset.changes[:total]
      assert updated_changeset.changes[:total] == Decimal.mult(Decimal.new(3), new_cost_price)
    end

    test "line item for non existent order" do
      product = TestSetup.Product.create_product
      master = product.master
      changeset =
        TestSetup.LineItem.line_item_changeset_with_variant(master)

      assert changeset.valid?
      {status, updated_changeset} = Repo.insert changeset
      assert status == :error
      assert errors_on(updated_changeset)[:order_id] == "does not exist"
    end
  end
end
