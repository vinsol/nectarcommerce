defmodule Nectar.Query.LineItem do
  use Nectar.Query, model: Nectar.LineItem

  def in_order(%Nectar.Order{id: order_id}, query \\ Nectar.LineItem) do
    from c in query, where: c.order_id == ^order_id
  end

  def in_order(repo, order), do: repo.all(in_order(order))

  def with_variant(%Nectar.Variant{id: variant_id}, query \\ Nectar.LineItem) do
    from c in query, where: c.variant_id == ^variant_id
  end

  def with_variant(repo, variant), do: repo.all(with_variant(variant))

  def in_order_with_variant(order, variant),
    do: with_variant(variant, in_order(order))

  def in_order_with_variant(repo, order, variant),
    do: repo.one(in_order_with_variant(order, variant))
end
