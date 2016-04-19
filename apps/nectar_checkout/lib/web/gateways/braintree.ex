defmodule Nectar.Gateway.BrainTree do
  alias Nectar.Repo
  alias Commerce.Billing.Address
  alias Commerce.Billing.CreditCard
  alias Commerce.Billing
  alias Nectar.Billing.Gateways.BraintreeImpl

  def authorize(order, %{"nonce" => nonce}) do
    billing_address = get_billing_address(order)
    nonce = nonce
    case Billing.authorize(:braintree, String.to_float(Decimal.to_string(order.total)),
                      nonce,
                      billing_address: billing_address,
                      description: "Order No. #{order.id}") do
      {:ok, _}  -> {:ok}
      {:error, message} -> {:error, message}
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

  def client_token do
    {:ok, token} = BraintreeImpl.generate_client_token
    token
  end

end
