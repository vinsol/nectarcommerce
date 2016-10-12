defmodule Nectar.Workflow.Checkout.Shipping do
  alias Ecto.Multi

  def run(repo, order, params),
    do: repo.transaction(steps(repo, order, params))

  def order_with_preloads(repo, order) do
    order
    |> repo.preload([shipment_units: [
                        shipment: [:shipping_method, :adjustment],
                        line_items: [variant: :product]]])
  end

  def changeset_for_step(order, params \\ %{}) do
    Nectar.Order.shipping_changeset(order, params)
  end

  def steps(repo, order, params) do
    order = order_with_preloads(repo, order)
    changeset = changeset_for_step(order, params)
    Multi.new()
    |> Multi.append(pre_transition(repo, changeset))
    |> Multi.update(:order, changeset)
    |> Multi.run(:post, &(post_transition(repo, &1.order)))
  end

  defp pre_transition(_repo, _order_changeset) do
    Multi.new()
  end

  defp post_transition(repo, order) do
    Multi.new()
    |> Multi.run(:calculate_taxes, &(calculate_taxes(&1, repo, order)))
    |> repo.transaction
  end

  defp calculate_taxes(_changes, repo, order) do
    {:ok, Nectar.TaxCalculator.calculate_taxes(repo, order)}
  end
end
