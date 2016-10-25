defmodule Nectar.Workflow.AcquireStockFromVariant do
  alias Ecto.Multi

  def run(repo, variant, quantity), do: repo.transaction(steps(variant, quantity))

  def steps(variant, quantity) do
    changeset = Nectar.Variant.buy_changeset(variant, %{buy_count: quantity})
    Multi.new()
    |> Multi.update(:variant_acquire_stock, changeset)
  end
end
