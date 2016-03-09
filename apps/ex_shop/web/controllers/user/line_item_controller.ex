defmodule ExShop.User.LineItemController do
  use ExShop.Web, :controller

  alias ExShop.CartManager

  plug :scrub_params, "line_item" when action in [:create]

  # TODO:
  # 1. Copy proper error messgae instead of the generic one.
  # 2. Reset cart if not in cart state.

  def create(conn, %{"line_item" => line_item_params}) do
    {:ok, order} = ExShop.CheckoutManager.back(conn.assigns.current_order, "cart")
    product = ExShop.Repo.get!(ExShop.Product, line_item_params["product_id"])
    case CartManager.add_to_cart(order, line_item_params) do
      {:ok, _line_item} ->
        conn
        |> put_flash(:success, "Added product succcesfully")
        |> redirect(to: cart_path(conn, :show))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Something went wrong please select the proper variant and try again")
        |> redirect(to: product_path(conn, :show, product))
    end
  end

  def delete(conn, %{"id" => id}) do
    line_item = Repo.get!(ExShop.LineItem, id)
    ExShop.Repo.delete!(line_item)
    conn
    |> put_flash(:success, "Removed product succesfully")
    |> redirect(to: cart_path(conn, :show))
  end


end
