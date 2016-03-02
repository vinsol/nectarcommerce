defmodule ExShop.Gateway do
  def authorize_payment(order, selected_payment_id, payment_method_params) do
    do_authorize_payment(order, selected_payment_method(order, selected_payment_id), payment_method_params)
  end

  defp selected_payment_method(order, selected_payment_id) do
    Enum.filter(order.payments, &(&1.id == selected_payment_id))
    |> List.first
    |> Map.get(:payment_method)
    |> Map.get(:name)
  end

  defp do_authorize_payment(order, "stripe", payment_method_params) do
    ExShop.Gateway.Stripe.authorize(order, payment_method_params["stripe"])
  end

  defp do_authorize_payment(order, "braintree", payment_method_params) do
    ExShop.Gateway.BrainTree.authorize(order, payment_method_params["braintree"])
  end

  defp do_authorize_payment(order, "new_payment_gateway", payment_method_params) do
    ExShop.Billing.Gateway.NewPaymentGateway.authorize(order, payment_method_params["new_payment_gateway"])
  end

  defp do_authorize_payment(_order, "cheque", _params) do
    {:ok}
  end
end
