defmodule ExShop.Admin.LineItemController do
  use ExShop.Web, :controller

  alias ExShop.Order
  alias ExShop.LineItem
  alias ExShop.CartManager

  plug :scrub_params, "line_item" when action in [:create]

  def create(conn, %{"line_item" => line_item_params}) do
    case CartManager.add_to_cart(conn.params["order_id"], line_item_params) do
      {:ok, line_item} ->
        conn
        |> put_status(201)
        |> render("line_item.json", line_item: line_item)
      {:error, changeset} ->
        conn
        |> put_status(422)
        |> render("error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    line_item = Repo.get!(LineItem, id)
    Repo.delete!(line_item)
    conn
    |> put_status(:no_content)
    |> json(nil)
  end

end
