defmodule Nectar.CartView do
  use Nectar.Web, :view

  def cart_empty?(%Nectar.Order{line_items: []}), do: true
  def cart_empty?(%Nectar.Order{} = _order), do: false
end
