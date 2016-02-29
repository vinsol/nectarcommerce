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

  def before_transition(order, "address", _params) do
    order
    |> Order.confirm_availability
  end

  def before_transition(order, "confirmation", _params) do
    order
    |> Order.confirm_availability
  end

  def before_transition(order, "payment", params) do
    order
    |> authorize_payment(params)
  end


  # default match do nothing just return order
  def before_transition(order, _to, _data), do: order


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
      |> Order.transition_changeset(next_state, params)
      |> before_transition(next_state, params)
      |> ExShop.Repo.update

    case status do
      :ok -> {:ok, after_transition(model, params)}
      :error -> {:error, model}
    end
  end

  # TODO: move these methods to gateway
  defp authorize_payment(order, params) do
    # get the selected payment method
    # if none or more than one found return changeset it will handle missing payment method later
    # else use the selected payment_method_id to complete the transaction.
    case Enum.filter(params["payments"] || [], fn
      ({_, %{"selected" => "false"}}) -> false
      ({_, %{"selected" => "true"}})  -> true
    end) do
      [{_, %{"id" => selected_payment_id}}] -> do_authorize_payment(order, String.to_integer(selected_payment_id), params["payment_method"])
      _  -> order
    end
  end

  defp do_authorize_payment(order, selected_payment_id, payment_method_params) do
    # in case payment fails add the error message to changeset to prevent it from moving to next state.
    case ExShop.Gateway.authorize_payment(order.model, selected_payment_id, payment_method_params) do
      {:ok} -> order
      {:error, error_message} -> order |> Ecto.Changeset.add_error(:payments, error_message)
    end
  end

end
