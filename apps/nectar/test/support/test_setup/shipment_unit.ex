defmodule Nectar.TestSetup.ShipmentUnit do
  def create_shipment_units do
    cart = Nectar.TestSetup.Order.setup_cart
    Nectar.Shipment.Splitter.make_shipment_units(cart)
  end
end
