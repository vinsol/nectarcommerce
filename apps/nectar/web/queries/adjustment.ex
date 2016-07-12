defmodule Nectar.Query.Adjustment do
  use Nectar.Query, model: Nectar.Adjustment

  def for_order(%Nectar.Order{id: order_id}) do
    from p in Nectar.Adjustment,
    where: p.order_id == ^order_id
  end

  def for_order(repo, order), do: repo.all(for_order order)

end
