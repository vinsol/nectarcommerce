defmodule Nectar.TestSetup.Order do
  alias Nectar.Repo
  alias Nectar.Order
  alias Nectar.CheckoutManager
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

  def move_cart_to_address_state(cart, params \\ nil) do
    address_params = params || valid_address_params
    CheckoutManager.next(cart, address_params)
  end

  defp valid_address_params do
    address = Nectar.TestSetup.Address.valid_attrs_with_country_and_state!
    %{"order_shipping_address" => address, "order_billing_address" => address}
  end

  def move_cart_to_shipping_state(cart) do
    CheckoutManager.next(cart, valid_shipping_params(cart))
  end
  defp valid_shipping_params(cart) do
    [%{id: shipping_method_id}|_] = Nectar.TestSetup.ShippingMethod.create_shipping_methods
    shipment_unit_id =
      cart
      |> Repo.preload([:shipment_units])
      |> Map.get(:shipment_units)
      |> List.first
      |> Map.get(:id)
    %{"shipment_units" => %{ "0" => %{"shipment" => %{"shipping_method_id" => shipping_method_id}, "id" => shipment_unit_id}}}
  end

  def move_cart_to_tax_state(cart) do
    CheckoutManager.next(cart, %{"tax_confirm" => true})
  end

  def move_cart_to_payment_state(cart) do
    CheckoutManager.next(cart, valid_payment_params(cart))
  end

  def move_cart_to_confirmation_state(cart) do
    CheckoutManager.next(cart, %{"confirm" => true})
  end

  defp valid_payment_params(_cart) do
    [%{id: payment_method_id}|_] = Nectar.TestSetup.PaymentMethod.create_payment_methods
    %{"payment" => %{"payment_method_id" => payment_method_id}, "payment_method" => %{}}
  end


end
