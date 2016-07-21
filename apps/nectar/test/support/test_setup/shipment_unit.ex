defmodule Nectar.TestSetup.ShipmentUnit do
  def create_shipment_units do
    cart = Nectar.TestSetup.Order.setup_cart
    {:ok, %{shipment_units: shipment_units}} =
      Nectar.Workflow.CreateShipmentUnits.run(Nectar.Repo, cart)
    shipment_units
  end
end
