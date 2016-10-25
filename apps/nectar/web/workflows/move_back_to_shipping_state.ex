defmodule Nectar.Workflow.MoveBackToShippingState do
  alias Ecto.Multi

  def run(repo, order), do: repo.transaction(steps(order))

  def steps(order) do
    Multi.new()
    |> Multi.delete_all(:delete_payments, Nectar.Query.Payment.for_order(order))
    |> Multi.update(:update_state, Nectar.Order.state_changeset(order, %{state: "shipping"}))
  end
end
