defmodule Nectar.Admin.UserOrderView do
  use NectarCore.Web, :view

  alias Nectar.Order

  def render("pending_orders.json", %{orders: orders, conn: conn}) do
    Enum.map(orders, fn (%Order{state: state, inserted_at: inserted_at} = order)->
      %{edit_cart_link: NectarRoutes.admin_cart_path(conn, :edit, order),
        state: state,
        created_on: inserted_at,
        continue_checkout_link: NectarRoutes.admin_order_checkout_path(conn, :checkout, order)} end)
  end
end
