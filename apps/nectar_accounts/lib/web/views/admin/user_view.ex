defmodule Nectar.Admin.UserView do
  use NectarCore.Web, :view

  def render("pending_orders.json", %{orders: orders, conn: conn}) do
    Enum.map(orders, fn (order)->
      %{edit_cart_link: NectarRoutes.admin_cart_path(conn, :edit, order),
        state: order.state,
        created_on: order.inserted_at,
        continue_checkout_link: NectarRoutes.admin_order_checkout_path(conn, :checkout, order)} end)
  end

end
