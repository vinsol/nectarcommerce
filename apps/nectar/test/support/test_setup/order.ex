defmodule Nectar.TestSetup.Order do
  alias Nectar.Repo
  alias Nectar.Order
  import Nectar.TestSetup.ShipmentUnit, only: [create_shipment_units: 0]

  def order_with_shipment_units do
    shipment_units = create_shipment_units
    Repo.get(Order, List.first(shipment_units).order_id)
  end

  def create_cart do
    Order.cart_changeset(%Order{}, %{}) |> Repo.insert!
  end

end
