defmodule Nectar.Query.Adjustment do
  use Nectar.Query, model: Nectar.Adjustment

  def for_order(%Nectar.Order{id: order_id}) do
    from p in Nectar.Adjustment,
    where: p.order_id == ^order_id
  end

  def for_order(repo, order), do: repo.all(for_order order)

  def tax_adjustments_for_order(order),
    do: from o in for_order(order), where: not(is_nil(o.tax_id))

  def shipment_adjustements_for_order(order),
    do: from o in for_order(order), where: not(is_nil(o.shipment_id))

end
