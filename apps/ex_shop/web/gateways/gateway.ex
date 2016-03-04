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
    # ExShop.Billing.Gateway.NewPaymentGateway.authorize(order, payment_method_params["new_payment_gateway"])
    # Use Commerce.Billing instead of Module implementing authorise
    # to leverage GenServer created for each payment Gateway
    # Below, will dispatch authorise to the dedicated GenServer for it
    # which in turn will call App Module implementing authorise
    # Direct call like above will leave the GenServer created useless / idle
    # Refer web/gateways/braintree_impl.ex on example to extract Billing Address
    Commerce.Billing.authorize(:new_payment_gateway,
      String.to_float(Decimal.to_string(order.total)),
      "123",
      billing_address: %Commerce.Billing.Address{
        street1: "House No - Unknown",
        street2: "Street Name",
        city:    "City Name",
        region:  "India",
        country: "India",
        postal_code: "121005"
      },
      description: "Order No. #{order.id}"
    )
  end

  defp do_authorize_payment(_order, "cheque", _params) do
    {:ok}
  end
end
