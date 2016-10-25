defmodule Nectar.Query.OrderShippingAddress do
  use Nectar.Query, model: Nectar.OrderShippingAddress

  def for_order(order),
    do: from o in Nectar.OrderShippingAddress, where: o.order_id == ^order.id

end
