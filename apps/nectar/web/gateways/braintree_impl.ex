defmodule Nectar.Billing.Gateways.BraintreeImpl do
  use Commerce.Billing.Gateways.Base

  alias Braintree.ClientToken
  alias Braintree.Transaction

  def authorize(amount, nonce, _options) do
    Transaction.sale(%{amount: amount, payment_method_nonce: nonce})
    |> respond
  end

  def generate_client_token do
    ClientToken.generate()
  end

  defp respond({:error, %Braintree.ErrorResponse{} = error}) do
    IO.puts inspect(error)
    {:error, "please check the card details"}
  end

  defp respond({:ok, %Braintree.Transaction{}}) do
    {:ok, "transaction successful"}
  end

  def capture(transaction_id, opts) do
    capture_amount = Keyword.get(opts, :amount)
    if capture_amount do
      Transaction.submit_for_settlement(transaction_id, %{amount: capture_amount})
    else
      Transaction.submit_for_settlement(transaction_id, %{})
    end
  end

  def refund(transaction_id, opts) do
    refund_amount = Keyword.get(opts, :amount)
    if refund_amount do
      Transaction.refund(transaction_id, %{amount: refund_amount})
    else
      Transaction.refund(transaction_id, %{})
    end
  end

end
