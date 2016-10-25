defmodule Nectar.Workflow.MoveBackToAddressState do
  alias Ecto.Multi

  def run(repo, order),
    do: repo.transaction(steps(order))

  def steps(order) do
    Multi.new()
    |> Multi.delete_all(:delete_payment, Nectar.Query.Payment.for_order(order))
    |> Multi.delete_all(:delete_tax_adjustments, Nectar.Query.Adjustment.tax_adjustments_for_order(order))
    |> Multi.delete_all(:delete_shipment_adjustments, Nectar.Query.Adjustment.shipment_adjustments_for_order(order))
    |> Multi.delete_all(:delete_shipment_units, Nectar.Query.ShipmentUnit.for_order(order))
    |> Multi.update(:update_state, Nectar.Order.state_changeset(order, %{state: "address"}))
  end

end
