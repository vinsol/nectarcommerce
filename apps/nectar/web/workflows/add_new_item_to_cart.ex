defmodule Nectar.Workflow.AddNewItemToCart do
  alias Ecto.Multi

  def steps(repo, variant, cart, quantity) do
    changeset = line_item_insert_changeset(variant, cart, quantity)
    Multi.new()
    |> Multi.run(:changeset_validity, &(ensure_changeset_is_valid(&1, changeset)))
    |> Multi.run(:variant_validity, &(ensure_product_has_no_variants_if_master(&1, repo, variant, changeset)))
    |> Multi.append(Nectar.Workflow.CheckVariantAvailability.steps(variant, quantity, changeset))
    |> Multi.insert(:line_item, changeset)
  end

  defp ensure_changeset_is_valid(_changes, changeset) do
    if changeset.valid? do
      {:ok, true}
    else
      {:error, changeset}
    end
  end

  defp ensure_product_has_no_variants_if_master(_changes, repo, variant, changeset) do
    variant = variant |> repo.preload([:product])
    product = variant.product
    if variant.is_master and Nectar.Query.Product.has_variants_excluding_master?(repo, product) do
      {:error, Ecto.Changeset.add_error(changeset, :variant, "cannot add master variant to cart when other variants are present.")}
    else
      {:ok, true}
    end
  end

  defp line_item_insert_changeset(variant, cart, quantity) do
    variant
    |> Ecto.build_assoc(:line_items)
    |> Nectar.LineItem.changeset(%{order_id: cart.id, unit_price: variant.cost_price, add_quantity: quantity})
  end

  def run(repo, variant, cart, quantity) do
    steps(repo, variant, cart, quantity)
    |> repo.transaction
  end

end
