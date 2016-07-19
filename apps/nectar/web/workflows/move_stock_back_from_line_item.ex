defmodule Nectar.Workflow.MoveStockBackFromLineItem do
  def run(repo, variant, restock_quantity), do: repo.transaction(steps(variant, restock_quantity))

  def steps(variant, quantity) do
    changeset = Nectar.Variant.restocking_changeset(variant, %{restock_count: quantity})
    Multi.new()
    |> Multi.update(:variant_restock, changeset)
  end
end
