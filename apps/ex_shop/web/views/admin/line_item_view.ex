defmodule ExShop.Admin.LineItemView do

  use ExShop.Web, :view

  def render("line_item.json", %{line_item: line_item}) do
    %{id: line_item.id, quantity: line_item.quantity, product: %{name: line_item.product.name, id: line_item.product.id}}
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
