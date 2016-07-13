defmodule Nectar.Query.Product do
  use Nectar.Query, model: Nectar.Product

  def has_variants_excluding_master?(repo, product) do
    repo.one(count_variants_excluding_master(product)) > 0
  end

  def count_variants_excluding_master(product) do
    from variant in all_variants_excluding_master(product), select: count(variant.id)
  end

  def all_variants_excluding_master(model) do
    from variant in all_variants_including_master(model), where: not(variant.is_master)
  end

  def all_variants_including_master(model) do
    from variant in Ecto.assoc(model, :variants)
  end

  def count_all_variants(product) do
    from variant in all_variants_including_master(product), select: count(variant.id)
  end

  def count_all_variants(repo, product) do
    repo.one(count_all_variants(product))
  end

  def master_variant(product) do
    from variant in all_variants_including_master(product), where: variant.is_master
  end

  def master_variant(repo, product) do
    repo.one(master_variant(product))
  end

  def products_with_master_variant do
    from p in Nectar.Product, preload: [master: ^Nectar.Query.Variant.master_variants]
  end

  def products_with_master_variant(repo), do: repo.all(products_with_master_variant)

  def products_with_variants do
    from p in Nectar.Product, preload: [master: ^Nectar.Query.Variant.master_variants, variants: ^Nectar.Query.Variant.not_master_variants]
  end

  def products_with_variants(repo), do: repo.all(products_with_variants)

  def product_with_master_variant(product_id) do
    from p in products_with_master_variant, where: p.id == ^product_id
  end

  def product_with_master_variant(repo, product_id), do: repo.one(product_with_master_variant(product_id))

  def product_with_variants(product_id) do
    from p in products_with_variants, where: p.id == ^product_id
  end

  def product_with_variants(repo, product_id), do: repo.one(product_with_variants(product_id))

end
