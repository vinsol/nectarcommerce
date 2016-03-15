defmodule Nectar.Gateway do
  def authorize_payment(order, selected_payment_id, payment_method_params) do
    do_authorize_payment(order, selected_payment_method(selected_payment_id), payment_method_params)
  end

  defp selected_payment_method(selected_payment_id) do
    Nectar.Repo.get!(Nectar.PaymentMethod, selected_payment_id) |> Map.get(:name)
  end

  defp do_authorize_payment(order, "stripe", payment_method_params) do
    Nectar.Gateway.Stripe.authorize(order, payment_method_params["stripe"])
  end

  defp do_authorize_payment(order, "braintree", payment_method_params) do
    Nectar.Gateway.BrainTree.authorize(order, payment_method_params["braintree"])
  end

  defp do_authorize_payment(_order, "cheque", _params) do
    {:ok}
  end
end
