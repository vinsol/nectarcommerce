defmodule ExShop.CartController do
  use ExShop.Web, :controller

  def show(conn, _) do
    order =
      conn.assigns.current_order
      |> Repo.preload([line_items: [variant: [:product, option_values: :option_type]]])
    render(conn, "show.html", order: order)
  end
end
