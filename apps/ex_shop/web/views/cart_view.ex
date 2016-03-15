defmodule ExShop.CartView do
  use ExShop.Web, :view

  def cart_empty?(%ExShop.Order{line_items: []}), do: true
  def cart_empty?(%ExShop.Order{} = _order), do: false
end
