defmodule Nectar.Admin.UserView do
  use Nectar.Web, :view

  def render("pending_orders.json", %{orders: orders}) do
    Enum.map(orders, fn (%Nectar.Order{} = order)->
      %{edit_cart_link: admin_cart_path(Nectar.Endpoint, :edit, order),
        state: order.state,
        created_on: order.inserted_at,
        continue_checkout_link: admin_order_checkout_path(Nectar.Endpoint, :checkout, order)}
    end)
  end

end
