defmodule Nectar.CartController do
  use NectarCore.Web, :controller

  def show(conn, _) do
    order =
      conn.assigns.current_order
      |> Repo.preload([line_items: [variant: [:product, option_values: :option_type]]])
    order_changeset = Nectar.Order.cart_update_changeset(order, %{})
    render(conn, "show.html", order: order, order_changeset: order_changeset)
  end

  def update(conn, %{"order" => order_params}) do
    order =
      conn.assigns.current_order
      |> Repo.preload([line_items: [variant: [:product, option_values: :option_type]]])
    order_changeset = Nectar.Order.cart_update_changeset(order, order_params)
    case Repo.update order_changeset do
      {:ok, _updated_order} ->
        conn
        |> put_flash(:success, "updated order succesfully")
        |> redirect(to: NectarRoutes.cart_path(conn, :show))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "failed to update. Please see the errors below")
        |> render("show.html", order: order, order_changeset: order_changeset)
    end
  end

end
