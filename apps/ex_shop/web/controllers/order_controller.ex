defmodule ExShop.OrderController do
  use ExShop.Web, :controller
  alias ExShop.Order

  def show(conn, %{"id" => id}) do
    order = Repo.get(Order, id)
    if order do
      order = order
              |> Repo.preload([line_items: [variant: [:product, [option_values: :option_type]]]])
              |> Repo.preload([shipping: [:shipping_method, :adjustment]])
              |> Repo.preload([adjustments: [:tax, :shipping]])
              |> Repo.preload([payment: [:payment_method]])
      render(conn, "show.html", order: order)
    else
      conn
        |> put_flash(:info, "Order Not found with id #{id}")
        |> redirect(to: admin_order_path(conn, :index))
        |> halt()
    end
  end
end
