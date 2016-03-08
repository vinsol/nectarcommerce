defmodule ExShop.Admin.UserView do
  use ExShop.Web, :view

  def render("pending_orders.json", %{orders: orders}) do
    Enum.map(orders, fn (%ExShop.Order{} = order)->
      %{edit_cart_link: admin_cart_path(ExShop.Endpoint, :edit, order),
        state: order.state,
        created_on: order.created_on,
        continue_checkout_link: admin_order_checkout_path(ExShop.Endpoint, :checkout, order)}
    end)
  end

end
