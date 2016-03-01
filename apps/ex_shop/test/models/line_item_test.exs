defmodule ExShop.LineItemTest do
  use ExShop.ModelCase

  alias ExShop.Repo
  alias ExShop.LineItem
  alias ExShop.Order
  alias ExShop.Product
  alias ExShop.Variant

  @order_attr   %{}

  @product_data %{name: "Sample Product",
    description: "Sample Product for testing without variant",
    available_on: Ecto.Date.utc,
  }
  @max_master_quantity 3
  @master_cost_price Decimal.new("30.00")
  @product_master_variant_data %{
    master: %{
      cost_price: @master_cost_price,
      add_count: @max_master_quantity
    }
  }
  @product_attr Map.merge(@product_data, @product_master_variant_data)

  @tag :pending
  test "LineItem Mgmt with variants and not only master variant" do
  end

  test "line item with available quantity" do
    changeset = create_line_item_with_product_quantity(2)
    assert changeset.errors == []
  end

  test "line item with unavailable quantity" do
    changeset = create_line_item_with_product_quantity(@max_master_quantity + 2)
    refute changeset.valid?
    assert changeset.errors[:quantity] == "only #{@max_master_quantity} available"
  end

  test "line item with 0 quantity" do
    changeset = create_line_item_with_product_quantity(0)
    refute changeset.valid?
    assert changeset.errors[:quantity] == {"must be greater than %{count}", [count: 0]}
  end

  test "adding product calculates total" do
    changeset = create_line_item_with_product_quantity(2)
    assert changeset.changes[:total] == Decimal.mult(Decimal.new("2"), @master_cost_price)
  end

  test "line item for non existent order" do
    changeset = create_line_item_with_product(-1)
    assert changeset.valid?
    {status, updated_changeset} = Repo.insert changeset
    assert status == :error
    assert updated_changeset.errors[:order_id] == "does not exist"
  end

  test "query by order" do
    line_item = create_line_item_with_product_quantity(2)
    |> Repo.insert!
    order = Repo.get Order, line_item.order_id
    assert line_item.id in Repo.all(from ln in LineItem.in_order(LineItem, order), select: ln.id)
  end

  test "query with product" do
    line_item = create_line_item_with_product_quantity(2)
    |> Repo.insert!
    variant = Repo.get Variant, line_item.variant_id
    assert line_item.id in Repo.all(from ln in LineItem.with_variant(LineItem, variant), select: ln.id)
  end

  defp create_order do
    Order.cart_changeset(%Order{}, %{})
    |> Repo.insert!
  end

  defp create_product do
    product = Product.create_changeset(%Product{}, @product_attr)
    |> Repo.insert!
    product.master
  end

  defp create_line_item_with_product(order_id \\ nil) do
    create_product
    |> Ecto.build_assoc(:line_items)
    |> LineItem.order_id_changeset(%{order_id: order_id || create_order.id})
  end

  defp create_line_item_with_product_quantity(quantity) do
    create_line_item_with_product
    |> LineItem.quantity_changeset(%{quantity: quantity})
  end

end
