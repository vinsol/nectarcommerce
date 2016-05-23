defmodule Nectar.Shipment.GeneratorTest do
  use Nectar.ModelCase
  alias Nectar.Order
  alias Nectar.CartManager
  alias Nectar.Product

  import Nectar.TestSetup.Order,          only: [setup_cart: 0, setup_cart_with_multiple_products: 0]
  import Nectar.TestSetup.ShippingMethod, only: [create_shipping_methods: 0]

  test "propose/1 takes the order and returns the applicable shippings" do
    create_shipping_methods
    cart = setup_cart |> Repo.preload([:line_items])
    Nectar.Shipment.Splitter.make_shipment_units(cart)
    applicable_shippings = Nectar.Shipment.Generator.propose(cart)
    assert Enum.count(applicable_shippings) == 1
  end

  test "propose/1 takes the order and returns multiple applicable shippings if multiple shipment units exist" do
    Application.put_env(:nectar, :shipment_splitter, Nectar.Shipment.Splitter.SplitAll)
    create_shipping_methods
    cart = setup_cart_with_multiple_products |> Repo.preload([:line_items])
    Nectar.Shipment.Splitter.make_shipment_units(cart)
    applicable_shippings = Nectar.Shipment.Generator.propose(cart)
    assert Enum.count(applicable_shippings) == 2
    Application.delete_env(:nectar, :shipment_splitter)
  end

end
