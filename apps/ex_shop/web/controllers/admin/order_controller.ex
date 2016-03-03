defmodule ExShop.Admin.OrderController do
  use ExShop.Web, :admin_controller

  plug Guardian.Plug.EnsureAuthenticated, handler: ExShop.Auth.HandleUnauthenticated, key: :admin

  alias ExShop.Order
  alias ExShop.Repo
  alias ExShop.LineItem
  alias ExShop.Product

  import Ecto.Query

  def index(conn, _params) do
    orders =
      Repo.all(from o in Order, order_by: o.id)
    render(conn, "index.html", orders: orders)
  end

  def show(conn, %{"id" => id}) do
    order =
      Repo.get(Order, id)
      |> Repo.preload([line_items: [variant: :product]])
      |> Repo.preload([shippings: [:shipping_method, :adjustment]])
      |> Repo.preload([adjustments: [:tax, :shipping]])
      |> Repo.preload([payments: [:payment_method]])
    render(conn, "show.html", order: order)
  end
end
