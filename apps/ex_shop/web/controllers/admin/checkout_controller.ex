defmodule ExShop.Admin.CheckoutController do
  use ExShop.Web, :controller

  alias ExShop.CheckoutManager
  alias ExShop.Order

  def checkout(conn, params) do
    order = Repo.get!(Order, conn.params["order_id"])
    render(conn, "checkout.html", order: order)
  end

  def next(conn, params) do
  end
end
