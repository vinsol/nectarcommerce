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

  describe "validations" do
    test "line item cannot add master variant if other variants present" do
      product = TestSetup.Product.create_product_with_multiple_variants
      master = product.master
      changeset = TestSetup.LineItem.line_item_changeset_with_variant master
      refute changeset.valid?
      assert errors_on(changeset)[:variant] == "cannot add master variant to cart when other variants are present."
    end

    test "line item with available quantity" do
      product = TestSetup.Product.create_product
      master = product.master
      changeset =
        TestSetup.LineItem.line_item_changeset_with_variant(master)
        |> TestSetup.LineItem.set_quantity(Nectar.Variant.available_quantity(master))
      assert changeset.errors == []
    end

    test "line item with unavailable quantity" do
      product = TestSetup.Product.create_product
      master = product.master
      available = Nectar.Variant.available_quantity(master)
      changeset =
        TestSetup.LineItem.line_item_changeset_with_variant(master)
        |> TestSetup.LineItem.set_quantity(available + 2)
      refute changeset.valid?
      assert errors_on(changeset)[:quantity] == "only #{available} available"
    end

    test "line item with out of stock product" do
      product = TestSetup.Product.create_product_with_oos_master
      master = product.master
      changeset =
        TestSetup.LineItem.line_item_changeset_with_variant(master)
        |> TestSetup.LineItem.set_quantity(1)
      refute changeset.valid?
      assert errors_on(changeset)[:variant] == "out of stock"
    end

    test "line item with 0 quantity" do
      product = TestSetup.Product.create_product
      master = product.master
      changeset =
        TestSetup.LineItem.line_item_changeset_with_variant(master)
        |> TestSetup.LineItem.set_quantity(0)
      refute changeset.valid?
      assert errors_on(changeset)[:quantity] == "must be greater than 0"
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

      Repo.update! Variant.update_master_changeset(master, %{cost_price: new_cost_price, discontinue_on: Ecto.Date.utc})

      updated_changeset = LineItem.quantity_changeset(original_changeset, %{add_quantity: 1})

      assert updated_changeset.valid?
      refute total == updated_changeset.changes[:total]
      refute updated_changeset.changes[:total] == Decimal.mult(Decimal.new(3), new_cost_price)
      assert updated_changeset.changes[:total] == Decimal.mult(Decimal.new(3), master.cost_price)
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

  describe "queries" do
    test "query by order" do
      line_item = TestSetup.LineItem.create
      order = Repo.get Order, line_item.order_id
      assert line_item.id in Repo.all(from ln in LineItem.in_order(LineItem, order), select: ln.id)
    end

    test "query with product" do
      line_item = TestSetup.LineItem.create
      variant = Repo.get Variant, line_item.variant_id
      assert line_item.id in Repo.all(from ln in LineItem.with_variant(LineItem, variant), select: ln.id)
    end
  end

  describe "fullfillment" do
    test "cancel fulfillment does not work if order is not confirmed" do
      line_item = TestSetup.LineItem.create
      order_id = line_item.order_id
      order = Nectar.Repo.get(Nectar.Order, order_id)
      {status, changeset} = Nectar.LineItem.cancel_fullfillment(%Nectar.LineItem{line_item|order: order})
      assert status == :error
      assert errors_on(changeset)[:fullfilled] == "Order should be in confirmation state before updating the fullfillment status"
    end

    test "cancel fullfillment on confirmed order updates the order status and total" do
      line_item = TestSetup.LineItem.create
      order_id = line_item.order_id
      order = Nectar.Repo.get(Nectar.Order, order_id) |> Nectar.Repo.preload([:line_items])

      assert order.state == "cart"
      assert Enum.count(order.line_items) == 1

      {:ok, c_addr} = Nectar.TestSetup.Order.move_cart_to_address_state(order)
      {:ok, c_shipp} = Nectar.TestSetup.Order.move_cart_to_shipping_state(c_addr)
      {:ok, c_tax} = Nectar.TestSetup.Order.move_cart_to_tax_state(c_shipp)
      {:ok, c_payment} = Nectar.TestSetup.Order.move_cart_to_payment_state(c_tax)
      {status,  c_confirm} = Nectar.TestSetup.Order.move_cart_to_confirmation_state(c_payment)

      assert status == :ok
      assert c_confirm.state == "confirmation"
      assert c_confirm.confirmation_status

      {_status, line_item} = Nectar.LineItem.cancel_fullfillment(%Nectar.LineItem{line_item|order: c_confirm})
      refute line_item.fullfilled

      updated_order = Nectar.Repo.get(Nectar.Order, order_id)
      # helper method for calculating the sum of adjustments.
      prod_diff = fn (order) -> Decimal.sub(order.total, order.product_total) end

      # order cancelled because only 1 line item in the order
      refute updated_order.confirmation_status
      # the order total changed
      assert updated_order.total != c_confirm.total
      # the product total also changed
      assert updated_order.product_total != c_confirm.product_total
      # the total of adjustments remain the same (product_total + adjustments = total)
      assert Decimal.compare(prod_diff.(updated_order), prod_diff.(c_confirm)) == Decimal.new("0")
    end
  end

end
