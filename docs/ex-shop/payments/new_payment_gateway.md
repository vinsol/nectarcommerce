step 1: Create a module which uses:   use Commerce.Billing.Gateways.Base
step 2: Implement the calls needed, there are 7 of them right now we need only authorize so implement the authorize method. this will be the part specific to payment gateway
  - Refer web/gateways/braintree_impl.ex ExShop.Billing.Gateways.BraintreeImpl
step 3: Write up a settings config for the payment gateway. you can use any format you like, we need to parse this later
 - config :ex_shop, :stripe,
  type: Commerce.Billing.Gateways.Stripe,
  credentials: {"sk_test_xxWBIVpjVpHmZpFUouu2GLa2", ""},
  default_currency: "USD"

step 4: in lib/ex_shop.ex, add a worker with the loaded configuration, you can see the other two for how it expect the configuration to be.
  - worker(Commerce.Billing.Worker, braintree_worker_configuration, id: :braintree)
  -   def braintree_worker_configuration do
    worker_config = Application.get_env(:ex_shop, :braintree)
    gateway_type = worker_config[:type]
    settings = %{}
    [gateway_type, settings, [name: :braintree]]
  end
step 5: in web/gateways/gateway.ex add a pattern match for it to dispatch to the worker if needed add a wrapper for bridging the data structures between what commerce billing expects and we are sending
  -   defp do_authorize_payment(order, "braintree", payment_method_params) do
    ExShop.Gateway.BrainTree.authorize(order, payment_method_params["braintree"])
  end
  - Refer web/gateways/braintree.ex :  ExShop.Gateway.BrainTree
step 6: Add an entry in db with the name used in pattern match
  - preferred is downcase payment method name :)
  - Add to lib/seed/create_payment_methods.ex : Seed.CreatePaymentMethod
step 7: create a payment.method-name.html.eex for getting the data from frontend
  - Refer web/templates/admin/checkout/payment.braintree.html.eex


Keeping Simple:

can I merge ExShop.Billing.Gateways.BraintreeImpl and ExShop.Gateway.BrainTree

and use only one

like

web/gateways/new_payment_gateway.ex

defmodule ExShop.Billing.Gateway.NewPaymentGateway do
  use Commerce.Billing.Gateways.Base

  def authorize(amount, nonce, options) do
    {:ok, "transaction successful"}
  end
end

Nimish Replied: yes you can, i separated them mostly to keep the code needed by our app and commerce billing seperate
