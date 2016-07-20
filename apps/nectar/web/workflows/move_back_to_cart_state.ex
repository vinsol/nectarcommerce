defmodule Nectar.Workflow.MoveBackToCartState do

  alias Ecto.Multi

  def run(repo, order), do: repo.transaction(steps(order))

  def steps(order) do
    Multi.new()
    |> Multi.delete_all(:delete_payment, Nectar.Query.Order.payment(order))
    |> Multi.delete_all(:delete_tax_adjustments, Nectar.Query.Order.tax_adjustments(order))
    |> Multi.delete_all(:delete_shipments, Nectar.Query.Order.shipments(order))
    |> Multi.delete_all(:delete_shipment_units, Nectar.Query.Order.shipment_units(order))
    |> Multi.delete_all(:delete_shipping_address, Nectar.Query.Order.shipping_address(order))
    |> Multi.delete_all(:delete_billing_address, Nectar.Query.Order.billing_address(order))
    |> Multi.update(:update_state, Nectar.Order.state_changeset(order, %{state: "cart"}))
  end

end
