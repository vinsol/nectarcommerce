defmodule Nectar.Query.OrderBillingAddress do
  use Nectar.Query, model: Nectar.OrderBillingAddress

  def for_order(order),
    do: from o in Nectar.OrderBillingAddress, where: o.order_id == ^order.id
end
