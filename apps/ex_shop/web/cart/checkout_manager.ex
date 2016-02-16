defmodule ExShop.CheckoutManager do

  alias ExShop.Order
  alias ExShop.ShippingCalculator
  alias ExShop.TaxCalculator
  alias ExShop.Invoice

  # States:
  # cart -> address -> shipping -> tax -> payment -> confirmation
  @states ~w(cart address shipping tax payment confirmation)

  def next_changeset(%Order{state: "cart"} = order), do: Order.transition_changeset(order, "address")
  def next_changeset(%Order{state: "address"} = order), do: Order.transition_changeset(order, "shipping")
  def next_changeset(%Order{state: "shipping"} = order), do: Order.transition_changeset(order, "tax")
  def next_changeset(%Order{state: "tax"} = order), do: Order.transition_changeset(order, "payment")
  def next_changeset(%Order{state: "payment"} = order), do: Order.transition_changeset(order, "confirmation")
  def next_changeset(%Order{} = order) do
    order
  end

  # transitions
  # TODO: metaprogram to autogenerate
  def next(%Order{state: "cart"} = order, params), do: to_state(order, "address", params)

  def next(%Order{state: "address"} = order, params), do: to_state(order, "shipping", params)

  def next(%Order{state: "shipping"} = order, params), do: to_state(order, "tax", params)

  def next(%Order{state: "tax"} = order, params), do: to_state(order, "payment", params)

  def next(%Order{state: "payment"} = order, params), do: to_state(order, "confirmation", params)

  def next(%Order{state: "confirmation"} = order, params), do: to_state(order, "confirmation", params)

  # TODO: move transitions to seperate modules ?
  def before_transition(order, next_state, data)

  def before_transition(%Order{} = order, "address", _params) do
    order
    |> Order.confirm_availability
  end

  def before_transition(%Order{} = order, "confirmation", _params) do
    order
    |> Order.confirm_availability
  end


  # default match do nothing just return order
  def before_transition(%Order{} = order, _to, _data), do: order


  def after_transition(%Order{state: "address"} = order, _data) do
    order
    |> ShippingCalculator.calculate_shippings
  end

  def after_transition(%Order{state: "shipping"} = order, _params) do
    order
    |> TaxCalculator.calculate_taxes
  end

  def after_transition(%Order{state: "tax"} = order, _data) do
    order
    |> Order.settle_adjustments_and_product_payments
    |> Invoice.generate
  end

  # default match do nothing just return order
  def after_transition(%Order{} = order, _data), do: order

  defp to_state(%Order{} = order, next_state, params) do
    {status, model} =
      order
      |> before_transition(next_state, params)
      |> Order.transition_changeset(next_state, params)
      |> ExShop.Repo.update
    case status do
      :ok -> {:ok, after_transition(model, params)}
      :error -> {:error, model}
    end
  end

end
