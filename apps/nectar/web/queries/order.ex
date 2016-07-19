defmodule Nectar.Query.Order do
  use Nectar.Query, model: Nectar.Order

  @default_total Decimal.new("0")
  def shipping_total(repo, order) do
    repo.one(
      from shipment_adj in Ecto.assoc(order, :adjustments),
      where: not is_nil(shipment_adj.shipment_id),
      select: sum(shipment_adj.amount)
    ) || @default_total
  end

  def tax_total(repo, order) do
    repo.one(
      from tax_adj in Ecto.assoc(order, :adjustments),
      where: not is_nil(tax_adj.tax_id),
      select: sum(tax_adj.amount)
    ) || @default_total
  end

  def product_total(repo, order) do
    repo.one(
      from line_item in Ecto.assoc(order, :line_items),
      where: line_item.fullfilled == true,
      select: sum(line_item.total)
    ) || @default_total
  end

  def can_be_fullfilled?(repo, order) do
    repo.all(from ln in Ecto.assoc(order, :line_items), select: ln.fullfilled)
    |> Enum.any?
  end

  def cart_empty?(repo, %Nectar.Order{} = order) do
    repo.one(from ln in Ecto.assoc(order, :line_items), select: count(ln.id)) == 0
  end

  def variants_in_cart(%Order{id: id} = order) do
    from v in assoc(order, :variants)
  end

  def out_of_stock_carts_sharing_variants_with(repo, order) do
    out_of_stock_variants_in_cart =
      repo.all(from v in Order.variants_in_cart(order),
        where: v.bought_quantity == v.total_quantity,
        select: v.id)
    repo.all(Order.with_variants_in_cart(out_of_stock_variants_in_cart))
  end

  def with_variants_in_cart(variant_ids) do
    from order in Nectar.Order,
      join: variant in assoc(order, :variants),
      where: variant.id in ^variant_ids,
      select: order
  end

end
