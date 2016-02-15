defmodule ExShop.Admin.CheckoutController do
  use ExShop.Web, :controller

  alias ExShop.CheckoutManager
  alias ExShop.Order

  def checkout(conn, params) do
    order = Repo.get!(Order, conn.params["order_id"])
    changeset = CheckoutManager.next_changeset(order)
    render(conn, "checkout.html", order: order, changeset: changeset)
  end

  def next(conn, %{"order" => order_params}) do
    order = Repo.get!(Order, conn.params["order_id"])
    updated_changeset = CheckoutManager.next(order, order_params)
    render(conn, "checkout.html", order: order, changeset: updated_changeset)
  end
end
