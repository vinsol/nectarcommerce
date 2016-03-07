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
  @master_variant_data %{
      cost_price: @master_cost_price,
      add_count: @max_master_quantity
  }
  @discontinued_master_variant_data Map.merge(@master_variant_data, %{discontinue_on: Ecto.Date.cast!("2016-03-01")})
  @product_master_variant_data %{
    master: @master_variant_data
  }
  @discontinued_product_master_variant_data %{
    master: @discontinued_master_variant_data
  }
  @product_attr Map.merge(@product_data, @product_master_variant_data)
  @discontinued_product_attr Map.merge(@product_data, @discontinued_product_master_variant_data)

  test "add to cart" do
    order = create_order
    product = create_product
    quantity = 2
    {status, line_item} = CartManager.add_to_cart(order.id, %{"variant_id" => product.master.id, "quantity" => quantity})
    assert status == :ok
    assert line_item.id in Repo.all(from lin in LineItem.in_order(LineItem, order), select: lin.id)
  end

  test "add to cart with unavailable quantity" do
    order = create_order
    product = create_product
    quantity = 4
    {status, line_item} = CartManager.add_to_cart(order.id, %{"variant_id" => product.master.id, "quantity" => quantity})
    assert status == :error
    assert line_item.errors[:quantity] == "only 3 available"
  end

  test "add to cart master variant, when other present" do
    order = create_order
    product = create_product_with_multiple_variant
    quantity = 1
    {status, line_item} = CartManager.add_to_cart(order.id, %{"variant_id" => product.master.id, "quantity" => quantity})
    assert status == :error
    assert line_item.errors[:variant] == "cannot add master variant to cart when other variants are present."
  end

  test "add to cart discontinued product" do
    order = create_order
    product = create_discontinued_product
    quantity = 1
    {status, line_item} = CartManager.add_to_cart(order.id, %{"variant_id" => product.master.id, "quantity" => quantity})
    assert status == :error
    assert line_item.errors[:variant] == "has been discontinued"
  end

  test "add to cart with 0 quantity" do
    order = create_order
    product = create_product
    quantity = 0
    {status, line_item} = CartManager.add_to_cart(order.id, %{"variant_id" => product.master.id, "quantity" => quantity})
    assert status == :error
    assert line_item.errors[:quantity] == {"must be greater than %{count}", [count: 0]}
  end

  test "add to cart with existing line item" do
    order = create_order
    product = create_product
    quantity = 1
    quantity_to_add = 2
    {_status, line_item} = CartManager.add_to_cart(order.id, %{"variant_id" => product.master.id, "quantity" => quantity})
    {updated_status, updated_line_item} = CartManager.add_to_cart(order.id, %{"variant_id" => product.master.id, "quantity" => quantity_to_add})
    assert updated_status == :ok
    assert line_item.id == updated_line_item.id
    refute updated_line_item.quantity == line_item.quantity
    assert updated_line_item.quantity == line_item.quantity + quantity_to_add
  end

  test "add to cart with existing line item and same quantity" do
    order = create_order
    product = create_product
    quantity = 1
    quantity_to_add = quantity
    {_status, line_item} = CartManager.add_to_cart(order.id, %{"variant_id" => product.master.id, "quantity" => quantity})
    {updated_status, updated_line_item} = CartManager.add_to_cart(order.id, %{"variant_id" => product.master.id, "quantity" => quantity_to_add})
    assert updated_status == :ok
    assert line_item.id == updated_line_item.id
    refute updated_line_item.quantity == line_item.quantity
    assert updated_line_item.quantity == line_item.quantity + quantity_to_add
  end


  defp create_order do
    Order.cart_changeset(%Order{}, %{})
    |> Repo.insert!
  end

  defp create_product do
    product = Product.create_changeset(%Product{}, @product_attr)
    |> Repo.insert!
  end

  @variant_attrs %{
    cost_price: "120.5",
    discontinue_on: %{"year" => "2016", "month" => "2", "day" => "1"},
    height: "120.5", weight: "120.5", width: "120.5",
    sku: "URG123"
  }

  defp create_product_with_multiple_variant do
    product = create_product
    product
    |> build_assoc(:variants)
    |> ExShop.Variant.create_variant_changeset(@variant_attrs)
    |> Repo.insert!
    product
  end

  defp create_discontinued_product do
    product = Product.create_changeset(%Product{}, @discontinued_product_attr)
    |> Repo.insert!
  end

end
