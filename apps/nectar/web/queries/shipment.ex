defmodule Nectar.Query.Shipment do
  use Nectar.Query, model: Nectar.Shipment

  def for_order(order) do
    from o in Nectar.Shipment,
      join: p in assoc(o, :shipment_unit),
      where: p.order_id == ^order.id
  end
end
