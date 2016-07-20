defmodule Nectar.Workflow.MoveBackToPaymentState do
  alias Ecto.Multi

  def run(repo, order), do: repo.transaction(steps(order))

  def steps(order) do
    Multi.new()
    |> Multi.update(:update_state, Nectar.Order.state_changeset(order, %{state: "payment"}))
  end

end
