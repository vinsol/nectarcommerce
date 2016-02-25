defmodule ExShop.Admin.LineItemView do

  use ExShop.Web, :view

  def render("line_item.json", %{line_item: line_item}) do
    line_item = ExShop.Repo.get!(ExShop.LineItem, line_item.id) |> ExShop.Repo.preload([variant: :product])
    if line_item.variant.is_master do
      %{id: line_item.id,
        quantity: line_item.quantity,
        variant: %{
          display_name: "#{line_item.variant.product.name}",
          id: line_item.variant.id}}
    else
      %{id: line_item.id,
        quantity: line_item.quantity,
        variant: %{
          display_name: "#{line_item.variant.product.name} (#{line_item.variant.sku})",
          id: line_item.variant.id}}
    end
  end

end
