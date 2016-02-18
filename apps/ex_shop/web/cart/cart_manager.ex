defmodule ExShop.CartManager do
  alias ExShop.Order
  alias ExShop.NotProduct, as: Product
  alias ExShop.LineItem
  alias ExShop.Repo
  import Ecto.Query

  def add_to_cart(order_id, %{"product_id" => product_id, "quantity" => quantity}) do
    order = Repo.get!(Order, order_id)
    product = Repo.get!(Product, product_id)
    do_add_to_cart(order, product, quantity)
  end

  defp do_add_to_cart(%Order{} = order, %Product{} = product, quantity) do
    find_or_build_line_item(order, product)
    |> LineItem.quantity_changeset(%{quantity: quantity})
    |> Repo.insert_or_update
  end


  defp find_or_build_line_item(order, product) do
    find_line_item(order, product) || build_line_item(order, product)
  end

  defp find_line_item(order, product) do
    LineItem
    |> LineItem.in_order(order)
    |> LineItem.with_product(product)
    |> Repo.one()
  end

  defp build_line_item(%Order{id: order_id} = order, %Product{} = product) do
    product
    |> Ecto.build_assoc(:line_items)
    |> LineItem.order_id_changeset(%{order_id: order_id})
  end
end
