defmodule ExShop.User.CheckoutController do
  use ExShop.Web, :controller

  alias ExShop.CheckoutManager
  alias ExShop.Order

  def checkout(conn, _params) do
    order = conn.assigns.current_order
    changeset = CheckoutManager.next_changeset(order)
    render(conn, "checkout.html", order: order, changeset: changeset)
  end

  def next(conn, %{"order" => order_params}) do
    order = conn.assigns.current_order
    case CheckoutManager.next(order, order_params) do
      {:error, updated_changeset} ->
        render(conn, "checkout.html", order: order, changeset: updated_changeset)
      {:ok, updated_order} ->
        render(conn, "checkout.html", order: updated_order, changeset: CheckoutManager.next_changeset(updated_order))
    end
  end

  def back(conn, _params) do
    order = conn.assigns.current_order
    case CheckoutManager.back(order) do
      {:ok, updated_order} ->
        redirect(conn, to: admin_order_checkout_path(conn, :checkout, order))
    end
  end

end
