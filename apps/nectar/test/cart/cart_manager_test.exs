defmodule Nectar.CartManagerTest do
  use Nectar.ModelCase

  alias Nectar.CartManager

  alias Nectar.Repo
  alias Nectar.LineItem
  alias Nectar.TestSetup

  test "add to cart" do
    order = TestSetup.Order.create_cart
    product = TestSetup.Product.create_product
    quantity = 2
    {status, line_item} = CartManager.add_to_cart(order.id, %{"variant_id" => product.master.id, "quantity" => quantity})
    assert status == :ok
    assert line_item.id in Repo.all(from lin in LineItem.in_order(LineItem, order), select: lin.id)
  end

  test "add to cart with unavailable quantity" do
    order = TestSetup.Order.create_cart
    product = TestSetup.Product.create_product
    quantity = 4
    {status, line_item} = CartManager.add_to_cart(order.id, %{"variant_id" => product.master.id, "quantity" => quantity})
    assert status == :error
    assert errors_on(line_item)[:quantity] == "only 3 available"
  end

  test "add to cart master variant, when other present" do
    order = TestSetup.Order.create_cart
    product = TestSetup.Product.create_product_with_multiple_variants
    quantity = 1
    {status, line_item} = CartManager.add_to_cart(order.id, %{"variant_id" => product.master.id, "quantity" => quantity})
    assert status == :error
    assert errors_on(line_item)[:variant] == "cannot add master variant to cart when other variants are present."
  end

  test "add to cart discontinued product" do
    order = TestSetup.Order.create_cart
    product = TestSetup.Product.create_product_with_discontinued_master
    master_variant = product.master
    quantity = 1
    {status, line_item} = CartManager.add_to_cart(order.id, %{"variant_id" => master_variant.id, "quantity" => quantity})
    assert status == :error
    assert errors_on(line_item)[:variant] == "has been discontinued"
  end

  test "add to cart with 0 quantity" do
    order = TestSetup.Order.create_cart
    product = TestSetup.Product.create_product
    quantity = 0
    {status, line_item} = CartManager.add_to_cart(order.id, %{"variant_id" => product.master.id, "quantity" => quantity})
    assert status == :error
    assert errors_on(line_item)[:quantity] == "must be greater than 0"
  end

  test "add to cart with existing line item" do
    order = TestSetup.Order.create_cart
    product = TestSetup.Product.create_product
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
    order = TestSetup.Order.create_cart
    product = TestSetup.Product.create_product
    quantity = 1
    quantity_to_add = quantity
    {_status, line_item} = CartManager.add_to_cart(order.id, %{"variant_id" => product.master.id, "quantity" => quantity})
    {updated_status, updated_line_item} = CartManager.add_to_cart(order.id, %{"variant_id" => product.master.id, "quantity" => quantity_to_add})
    assert updated_status == :ok
    assert line_item.id == updated_line_item.id
    refute updated_line_item.quantity == line_item.quantity
    assert updated_line_item.quantity == line_item.quantity + quantity_to_add
  end
end
