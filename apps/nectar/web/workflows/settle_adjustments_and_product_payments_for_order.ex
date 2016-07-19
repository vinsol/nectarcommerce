defmodule Nectar.Workflow.SettleAdjustmentAndProductPaymentForOrder do
  alias Ecto.Multi

  def run(repo, order), do: repo.transaction(steps(repo, order))

  def steps(repo, order) do
    Multi.new()
    |> Multi.run(:shipping_total, &(calculate_shipping_total(&1, repo, order)))
    |> Multi.run(:product_total, &(calculate_product_total(&1, repo, order)))
    |> Multi.run(:tax_total, &(calculate_tax_total(&1, repo, order)))
    |> Multi.run(:fullfilled, &(can_be_fullfilled?(&1, repo, order)))
    |> Multi.run(:params, &(build_params(&1)))
    |> Multi.run(:update_product, &(Nectar.Command.Order.update_with_order_settlement(repo, order, &1.params)))
  end

  defp calculate_shipping_total(_changes, repo, order),
    do: Nectar.Query.Order.shipping_total(repo, order)

  defp calculate_product_total(_changes, repo, order),
    do: Nectar.Query.Order.product_total(repo, order)

  defp calculate_tax_total(_changes, repo, order),
    do: Nectar.Query.Order.tax_total(repo, order)

  defp can_be_fullfilled?(_changes, repo, order),
    do: Nectar.Query.Order.can_be_fullfilled?(repo, order)

  defp build_params(changes) do
    adjustment_total = Decimal.add(changes.shipping_total, changes.tax_total)
    total = Decimal.add(changes.product_total, adjustment_total)
    params = %{
      total:               total,
      product_total:       changes.product_total,
      confirmation_status: changes.fullfilled
    }
    {:ok, params}
  end

end
