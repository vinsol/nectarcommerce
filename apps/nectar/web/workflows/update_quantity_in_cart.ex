defmodule Nectar.Workflow.UpdateQuantityInCart do

  alias Ecto.Multi

  def run(repo, line_item, variant, quantity),
    do: repo.transaction(steps(line_item, variant, quantity))

  def steps(line_item, variant, quantity) do
    changeset = line_item_update_quantity_changeset(line_item, quantity)
    requested_quantity = line_item.quantity + quantity
    Multi.new()
    |> Multi.run(:changeset_validity, &(ensure_changeset_is_valid(&1, changeset)))
    |> Multi.append(Nectar.Workflow.CheckVariantAvailability.steps(variant, requested_quantity, changeset))
    |> Multi.update(:line_item, changeset)
  end

  defp ensure_changeset_is_valid(_changes, changeset) do
    if changeset.valid? do
      {:ok, true}
    else
      {:error, changeset}
    end
  end

  defp line_item_update_quantity_changeset(line_item, quantity) do
    Nectar.LineItem.quantity_changeset(line_item, %{add_quantity: quantity})
  end

end
