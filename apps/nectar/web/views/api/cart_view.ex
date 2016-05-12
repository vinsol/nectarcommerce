defmodule Nectar.Api.CartView do
  use Nectar.Web, :view
  def render("cart.json",  %{order: order, summary: "true"}) do
    %{
      items_in_cart: Nectar.CartManager.count_items_in_cart(order),
      id: order.id
    }
  end

  def render("cart.json", %{order: order}) do
    %{order_id: order.id}
  end
end
