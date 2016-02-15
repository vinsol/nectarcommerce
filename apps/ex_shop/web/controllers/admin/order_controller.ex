defmodule ExShop.Admin.OrderController do
  use ExShop.Web, :controller

  alias ExShop.Order
  alias ExShop.Repo
  alias ExShop.LineItem
  alias ExShop.NotProduct, as: Product

  import Ecto.Query

  def cart(conn, _params) do
    # create a blank cart, maybe add it to conn and plug it later on
    # order = Order.cart_changeset(%Order{}, %{}) |> Repo.insert!
    order = Repo.get(Order, 1)
    products  = Product |> select([c], {c.id, c.name}) |> Repo.all
    line_items =
      LineItem
      |> LineItem.in_order(order)
      |> Repo.all
      |> Repo.preload([:product])
    render(conn, "new.html", order: order, products: products, line_items: line_items)
  end

end
