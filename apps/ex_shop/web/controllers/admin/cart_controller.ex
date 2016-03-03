defmodule ExShop.Admin.CartController do
  use ExShop.Web, :admin_controller

  plug Guardian.Plug.EnsureAuthenticated, handler: ExShop.Auth.HandleUnauthenticated, key: :admin

  alias ExShop.Order
  alias ExShop.Repo
  alias ExShop.LineItem
  alias ExShop.Product

  import Ecto.Query


  def new(conn, _params) do
    # create a blank cart, maybe add it to conn and plug it later on
    order = Order.cart_changeset(%Order{}, %{}) |> Repo.insert!
    # order = Repo.get(Order, 1)
    products  =
      Product
      |> Repo.all
      |> Repo.preload([:variants])

    line_items =
      LineItem
      |> LineItem.in_order(order)
      |> Repo.all
      |> Repo.preload([variant: :product])
    render(conn, "new.html", order: order, products: products, line_items: line_items)
  end

  def edit(conn, %{"id" => id}) do
    {:ok, order} = Repo.get!(ExShop.Order, id) |> Order.move_back_to_cart_state
    products  =
      Product
      |> Repo.all
      |> Repo.preload([:variants])

    line_items =
      LineItem
      |> LineItem.in_order(order)
      |> Repo.all
      |> Repo.preload([variant: :product])
    render(conn, "new.html", order: order, products: products, line_items: line_items)
  end

end
