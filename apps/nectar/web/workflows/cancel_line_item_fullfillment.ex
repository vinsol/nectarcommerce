defmodule Nectar.Workflow.CancelLineItemFullfillment do
  alias Ecto.{Multi, Changeset}

  def run(repo, line_item), do: repo.transaction(steps(repo, line_item))

  # Caution: Ensure order and variant data is preloaded
  def steps(repo, line_item) do
    changeset = Nectar.LineItem.fullfillment_changeset(line_item, %{fullfilled: false})
    Multi.new()
    |> Multi.run(:changeset_is_valid, &(changeset_is_valid(&1, changeset)))
    |> Multi.run(:order_confirmed, &(ensure_order_is_confirmed(&1, line_item.order, changeset)))
    |> Multi.append(Nectar.Workflow.MoveStockBackFromLineItem.steps(line_item.variant, line_item.quantity))
    |> Multi.append(Nectar.Workflow.SettleAdjustmentAndProductPaymentForOrder.steps(repo, line_item.order))
  end

  defp changeset_is_valid(_changes, %Ecto.Changeset{valid?: true} = changeset),
    do: {:ok, changeset}

  defp changeset_is_valid(_changes, changeset),
    do: {:error, changeset}

  defp ensure_order_is_confirmed(_changes, order, changeset) do
    if Nectar.Order.confirmed?(order) do
      {:ok, changeset}
    else
      {:error, Changeset.add_error(changeset, :fullfilled, "Order should be in confirmation state before updating the fullfillment status")}
    end
  end

end
