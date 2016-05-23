defmodule Nectar.TestSetup.Order do
  alias Nectar.Repo
  alias Nectar.Order
  alias Nectar.CartManager
  import Nectar.TestSetup.ShipmentUnit, only: [create_shipment_units: 0]
  import Nectar.TestSetup.Product,      only: [create_product: 0, create_products: 0]


  def order_with_shipment_units do
    shipment_units = create_shipment_units
    Repo.get(Order, List.first(shipment_units).order_id)
  end

  def create_cart do
    Order.cart_changeset(%Order{}, %{}) |> Repo.insert!
  end

  def setup_cart do
    cart = create_cart
    product = create_product
    master_variant = product.master
    quantity = 2
    {_status, _line_item} = CartManager.add_to_cart(cart.id, %{"variant_id" => master_variant.id, "quantity" => quantity})
    cart
  end

  def setup_cart_with_multiple_products do
    cart = create_cart
    [product1, product2] = create_products
    [master_variant1, master_variant2] = [product1.master, product2.master]
    quantity = 2
    {_status, _line_item} = CartManager.add_to_cart(cart.id, %{"variant_id" => master_variant1.id, "quantity" => quantity})
    {_status, _line_item} = CartManager.add_to_cart(cart.id, %{"variant_id" => master_variant2.id, "quantity" => quantity})
    cart
  end


end
