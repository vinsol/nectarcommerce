defmodule Nectar.Query.Shipping do
  use Nectar.Query, model: Nectar.Shipping

  def for_order(%Nectar.Order{id: order_id}) do
    from p in Nectar.Shipping,
    where: p.order_id == ^order_id
  end

  def for_order(repo, order), do: repo.all(for_order(order))

end
