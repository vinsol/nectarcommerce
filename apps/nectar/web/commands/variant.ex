defmodule Nectar.Command.Variant do
  use Nectar.Command, model: Nectar.Variant

  def insert_for_product(repo, product, params) do
    product
    |> Ecto.build_assoc(:variants)
    |> Nectar.Variant.create_variant_changeset(product, params)
    |> repo.insert
  end

  def update_for_product(repo, variant, product, params) do
    Nectar.Variant.update_variant_changeset(variant, product, params)
    |> repo.update
  end

end
