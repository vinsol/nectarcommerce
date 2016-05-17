# Simple Adapter Class Around commerce billing
# Based on the code in checkout controller of https://github.com/joshnuss/phoenix-billing-demo
defmodule Nectar.Gateway.Stripe do
  alias Nectar.Repo
  alias Commerce.Billing.Address
  alias Commerce.Billing.CreditCard
  alias Commerce.Billing

  def authorize(order, card_details) do
    billing_address = get_billing_address(order)
    card =  get_card(card_details)
    case Billing.authorize(:stripe, String.to_float(Decimal.to_string(order.total)),
                      card,
                      billing_address: billing_address,
                      description: "Order No. #{order.id}") do
      {:ok, response}  ->
        {:ok, response.authorization}
      {:error, %Commerce.Billing.Response{raw: %{"error" => %{"message" => message}}}} -> {:error, message}
    end
  end

  def capture(transaction_id) do
    case Billing.capture(:stripe, transaction_id) do
      {:ok, _} -> {:ok}
      {:error, response} ->
        {:error, "failed to capture"}
    end
  end

  def refund(transaction_id, amount) do
    case Billing.refund(:stripe, String.to_float(Decimal.to_string(amount)), transaction_id) do
      {:ok, _} -> {:ok}
      {:error, response} ->
        import IEx
        IEx.pry
        {:error, "failed to refund"}
    end
  end

  def get_billing_address(order) do
    billing_address =
      order
      |> Repo.preload([billing_address: [:state, :country]])
      |> Map.get(:billing_address)
    %Address{
      street1: billing_address.address_line_1,
      street2: billing_address.address_line_2,
      city:    "",
      region:  billing_address.state.name,
      country: billing_address.country.name,
      postal_code: ""
    }
  end

  def get_card(card_details) do
    %CreditCard{
      number: card_details["card_number"],
      expiration: get_expiration(card_details["year"], card_details["month"]),
      cvc: card_details["cvc"]
    }
  end

  def get_expiration(year, month) when byte_size(year) > 0 and byte_size(month) > 0,
    do: {String.to_integer(year), String.to_integer(month)}

  def get_expiration(_, _),
    do: {0, 0}


end
