defmodule Nectar.Query.Payment do
  use Nectar.Query, model: Nectar.Payment

  def for_order(%Nectar.Order{id: order_id}) do
    from p in Nectar.Payment,
    where: p.order_id == ^order_id
  end

end
