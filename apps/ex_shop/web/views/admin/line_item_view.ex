defmodule ExShop.Admin.LineItemView do

  use ExShop.Web, :view

  def render("line_item.json", %{line_item: line_item}) do
    line_item = ExShop.Repo.get!(ExShop.LineItem, line_item.id) |> ExShop.Repo.preload([variant: :product])
    if line_item.variant.is_master do
      %{id: line_item.id, quantity: line_item.quantity, variant: %{display_name: "#{line_item.variant.product.name}", id: line_item.variant.id}}
    else
      %{id: line_item.id, quantity: line_item.quantity, variant: %{display_name: "#{line_item.variant.product.name} (#{line_item.variant.sku})", id: line_item.variant.id}}
    end
  end

  def render("error.json", %{changeset: changeset}) do
    errors = Enum.map(changeset.errors, fn {field, details} ->
      %{
        field: field,
        detail: render_detail(details)
       }
    end)
    %{errors: errors}
  end

  def render_detail({message, values}) do
    Enum.reduce values, message, fn {k, v}, acc ->
      String.replace(acc, "%{#{k}}", to_string(v))
    end
  end

  def render_detail(message) do
    message
  end

end
