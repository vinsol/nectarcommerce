defmodule Nectar.TestSetup.LineItem do
  alias Nectar.LineItem

  def line_item_changeset_with_variant(variant) do
    variant
    |> Ecto.build_assoc(:line_items)
    |> LineItem.create_changeset(%{order_id: -1, unit_price: variant.cost_price})
  end

  def set_quantity(changeset, quantity) do
    changeset
    |> LineItem.quantity_changeset(%{add_quantity: quantity})
  end

  def create do
    cart = Nectar.TestSetup.Order.setup_cart |> Nectar.Repo.preload([:line_items])
    cart.line_items |> List.first
  end
end
