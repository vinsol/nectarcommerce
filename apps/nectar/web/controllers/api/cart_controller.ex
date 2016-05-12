defmodule Nectar.Api.CartController do
  use Nectar.Web, :controller

  def show(conn, params) do
    order =
      conn.assigns.current_order
      |> Repo.preload([line_items: [variant: [:product, option_values: :option_type]]])

    render(conn, "cart.json", order: order, summary: Map.get(params, "summary", false))
  end

end
