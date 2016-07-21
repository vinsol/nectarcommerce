defmodule Nectar.Query.ShipmentUnit do
  use Nectar.Query, model: Nectar.ShipmentUnit

  def for_order(order),
    do: from o in Nectar.ShipmentUnit, where: o.order_id == ^order.id
end
