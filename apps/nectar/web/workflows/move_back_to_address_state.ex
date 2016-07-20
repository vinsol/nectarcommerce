defmodule Nectar.Workflow.MoveBackToAddressState do
  alias Ecto.Multi

  def run(repo, order),
    do: repo.transaction(steps(order))

  def steps(order) do
    Multi.new()
    |> Multi.delete_all(:delete_payment, Nectar.Query.Order.payment(order))
    |> Multi.delete_all(:delete_tax_adjustments, Nectar.Query.Order.tax_adjustments(order))
    |> Multi.delete_all(:delete_shipments, Nectar.Query.Order.shipments(order))
    |> Multi.update(:update_state, Nectar.Order.state_changeset(order, %{state: "address"}))
  end

end
