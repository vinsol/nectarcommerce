defmodule ExShop.CartManagerTest do
	use ExShop.ModelCase

  alias ExShop.CartManager

  alias ExShop.Repo
  alias ExShop.LineItem
  alias ExShop.Order
  alias ExShop.Product

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
      quantity: @max_master_quantity
    }
  }
  @product_attr Map.merge(@product_data, @product_master_variant_data)

  test "add to cart" do
    order = create_order
    product = create_product
    quantity = 2
    {status, line_item} = CartManager.add_to_cart(order.id, %{"variant_id" => product.id, "quantity" => quantity})
    assert status == :ok
    assert line_item.id in Repo.all(from lin in LineItem.in_order(LineItem, order), select: lin.id)
  end

  test "add to cart with unavailable quantity" do
    order = create_order
    product = create_product
    quantity = 4
    {status, line_item} = CartManager.add_to_cart(order.id, %{"variant_id" => product.id, "quantity" => quantity})
    assert status == :error
    assert line_item.errors[:quantity] == "only 3 available"
  end

  test "add to cart with 0 quantity" do
    order = create_order
    product = create_product
    quantity = 0
    {status, line_item} = CartManager.add_to_cart(order.id, %{"variant_id" => product.id, "quantity" => quantity})
    assert status == :error
    assert line_item.errors[:quantity] == {"must be greater than %{count}", [count: 0]}
  end


  test "add to cart with existing line item" do
    order = create_order
    product = create_product
    quantity = 1
    {_status, line_item} = CartManager.add_to_cart(order.id, %{"variant_id" => product.id, "quantity" => quantity})
    {updated_status, updated_line_item} = CartManager.add_to_cart(order.id, %{"variant_id" => product.id, "quantity" => 3})
    assert updated_status == :ok
    assert line_item.id == updated_line_item.id
    refute updated_line_item.quantity == line_item.quantity
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

end
