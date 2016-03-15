defmodule Nectar.Admin.CheckoutController do
  use Nectar.Web, :admin_controller

  plug Guardian.Plug.EnsureAuthenticated, handler: Nectar.Auth.HandleAdminUnauthenticated, key: :admin
  plug :go_back_to_cart_if_empty when action in [:checkout, :next, :back]

  alias Nectar.CheckoutManager
  alias Nectar.Order

  def checkout(conn, _params) do
    order = Repo.get!(Order, conn.params["order_id"])
    changeset = CheckoutManager.next_changeset(order)
    render(conn, "checkout.html", order: order, changeset: changeset)
  end

  def next(conn, %{"order" => order_params}) do
    order = Repo.get!(Order, conn.params["order_id"])
    case CheckoutManager.next(order, order_params) do
      {:error, updated_changeset} ->
        render(conn, "checkout.html", order: order, changeset: updated_changeset)
      {:ok, updated_order} ->
        render(conn, "checkout.html", order: updated_order, changeset: CheckoutManager.next_changeset(updated_order))
    end
  end

  def back(conn, _params) do
    order = Repo.get!(Order, conn.params["order_id"])
    case CheckoutManager.back(order) do
      {:ok, _updated_order} ->
        redirect(conn, to: admin_order_checkout_path(conn, :checkout, order))
    end
  end

  def go_back_to_cart_if_empty(conn, _params) do
    order = Repo.get!(Order, conn.params["order_id"])
    if Nectar.Order.cart_empty? order do
      conn
      |> put_flash(:error, "please add some products to cart before continuing")
      |> redirect(to: admin_cart_path(conn, :edit, order))
      |> halt
    else
      conn
    end
  end

end
