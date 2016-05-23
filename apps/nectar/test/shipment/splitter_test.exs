defmodule Nectar.Shipment.SplitterTest do
  use Nectar.ModelCase

  import Nectar.TestSetup.Order, only: [setup_cart: 0, setup_cart_with_multiple_products: 0]

  test "make_shipment_units/1 takes the order and splits it into shipment units" do
    cart = setup_cart
    shipments = [op]   = Nectar.Shipment.Splitter.make_shipment_units(cart)
    assert Enum.count(shipments) == 1
    assert op.__struct__ == Nectar.ShipmentUnit
  end

  test "make_shipment_units/1 uses the configured splitter if present" do
    Application.put_env(:nectar, :shipment_splitter, Nectar.Shipment.Splitter.SplitAll)

    cart = setup_cart_with_multiple_products
    shipments = Nectar.Shipment.Splitter.make_shipment_units(cart)
    op = List.first shipments
    assert Enum.count(shipments) == 2
    assert op.__struct__ == Nectar.ShipmentUnit
    Application.delete_env(:nectar, :shipment_splitter)
  end

end
