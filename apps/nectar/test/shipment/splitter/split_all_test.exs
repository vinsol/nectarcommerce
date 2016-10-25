defmodule Nectar.Shipment.Splitter.SplitAllTest do
  use Nectar.ModelCase

  alias Nectar.Order
  alias Nectar.CartManager
  alias Nectar.Product

  import Nectar.TestSetup.Order, only: [setup_cart: 0, setup_cart_with_multiple_products: 0]

  test "it splits the line items into 1 shipment unit" do
    cart = setup_cart |> Repo.preload([:line_items])
    [shipment_unit] = Nectar.Shipment.Splitter.SplitAll.split(cart)
    assert Enum.count(shipment_unit) == Enum.count(cart.line_items)
  end

  test "it splits multiple line items into seperate shipment unit" do
    cart = setup_cart_with_multiple_products |> Repo.preload([:line_items])
    shipment_units = Nectar.Shipment.Splitter.SplitAll.split(cart)
    shipment_unit = List.first shipment_units
    assert Enum.count(shipment_units) == 2
    assert Enum.count(shipment_unit)  == 1
  end

end
