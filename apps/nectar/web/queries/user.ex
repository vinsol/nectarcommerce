defmodule Nectar.Query.User do
  use Nectar.Query, model: Nectar.User

  def current_order(repo, user) do
    repo.one(
      from order in all_abandoned_orders(user),
      order_by: [desc: order.updated_at],
      limit: 1
    )
  end

  def all_abandoned_orders(%Nectar.User{} = user) do
    from order in all_orders(user),
      where: not(order.state == "confirmation")
  end

  def all_orders(%Nectar.User{id: id}) do
    from o in Nectar.Order,
      where: o.user_id == ^id
  end

end
