defmodule ExShop.Admin.OrderController do
  use ExShop.Web, :controller

  alias ExShop.Order
  alias ExShop.Repo
  alias ExShop.NotProduct

  import Ecto.Query

  def new(conn, _params) do
    # create a blank cart, maybe add it to conn and plug it later on
    # order = Order.changeset(%Order{}, %{}) |> Repo.insert!
    order = Repo.get(Order, 1)
    products  = NotProduct |> select([c], {c.id, c.name}) |> Repo.all
    render(conn, "new.html", order: order, products: products)
  end

end
