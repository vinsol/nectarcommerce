defmodule ExShop.CartManager do
  alias ExShop.Order
  alias ExShop.NotProduct, as: Product
  alias ExShop.LineItem
  alias ExShop.Repo
  import Ecto.Query

  # adding to cart zero quantity deletes the line item present
  def add_to_cart(%Order{} = order, %Product{} = product, quantity) when quantity == 0 do
    find_line_item(order, product)
    |> Repo.delete
  end

  # handle other cases
  def add_to_cart(%Order{} = order, %Product{} = product, quantity) do
    find_or_build_line_item(order, product)
    |> LineItem.quantity_changeset(%{quantity: quantity})
    |> Repo.insert_or_update
  end


  def find_or_build_line_item(order, product) do
    find_line_item(order, product) || build_line_item(order, product)
  end

  defp find_line_item(order, product) do
    LineItem
    |> LineItem.in_order(order)
    |> LineItem.with_product(product)
    |> Repo.one()
  end

  defp build_line_item(order, %Product{id: product_id}) do
    order
    |> Ecto.build_assoc(:line_items)
    |> LineItem.product_id_changeset(%{product_id: product_id})
  end
end
