defmodule ExShop.Billing.Gateways.NewPaymentGateway do
  use Commerce.Billing.Gateways.Base

  # undefined function ExShop.Billing.Gateway.NewPaymentGateway.authorize/2
  # Added :empty optional
  def authorize(amount, nonce, options \\ :empty) do
    # no case clause matching: {:ok, "transaction successful"}
    # case ExShop.Gateway.authorize_payment(order.model, selected_payment_id, payment_method_params)
    # web/cart/checkout_manager.ex
    #{:ok, "transaction successful"}
    {:ok}
  end
end
