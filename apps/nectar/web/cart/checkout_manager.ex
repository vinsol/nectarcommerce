defmodule Nectar.CheckoutManager do

  alias Nectar.Order
  alias Nectar.TaxCalculator

  # States:
  # cart -> address -> shipping -> tax -> payment -> confirmation
  @states ~w(cart address shipping tax payment confirmation)
  @state_transitions @states
                     |> Enum.zip(Enum.drop(@states, 1))
                     |> Enum.reduce(%{}, fn ({frm, to}, acc) -> Map.put_new(acc, frm, to) end)

  def next_changeset(%Order{state: "cart"} = order), do: Order.transition_changeset(order, "address")
  def next_changeset(%Order{state: "address"} = order), do: Order.transition_changeset(order, "shipping")
  def next_changeset(%Order{state: "shipping"} = order), do: Order.transition_changeset(order, "tax")
  def next_changeset(%Order{state: "tax"} = order), do: Order.transition_changeset(order, "payment")
  def next_changeset(%Order{state: "payment"} = order), do: Order.transition_changeset(order, "confirmation")
  def next_changeset(%Order{} = order), do: order

  # transitions
  # TODO: autogenerate the transitions

  def next(%Order{state: "cart"} = order, params),         do: to_state(order, "address", params)
  def next(%Order{state: "address"} = order, params),      do: to_state(order, "shipping", params)
  def next(%Order{state: "shipping"} = order, params),     do: to_state(order, "tax", params)
  def next(%Order{state: "tax"} = order, params),          do: to_state(order, "payment", params)
  def next(%Order{state: "payment"} = order, params),      do: to_state(order, "confirmation", params)
  def next(%Order{state: "confirmation"} = order, params), do: to_state(order, "confirmation", params)

  @nextable_states Enum.drop(Enum.reverse(@states), 1)
  def next_state(%Order{state: state}) when state in @nextable_states, do: Map.get(@state_transitions, state)
  def next_state(%Order{state: state}), do: state

  def back(order)

  def back(%Order{state: "address"} = order),  do: Order.move_back_to_cart_state(order)
  def back(%Order{state: "shipping"} = order), do: Order.move_back_to_address_state(order)
  def back(%Order{state: "tax"} = order),      do: Order.move_back_to_shipping_state(order)
  def back(%Order{state: "payment"} = order),  do: Order.move_back_to_tax_state(order)

  # cannot go back from confirmation or cart
  def back(%Order{state: _} = order), do: {:ok, order}


  Module.register_attribute(__MODULE__, :backable_states, accumulate: true)

  # when state is specified
  # helper method used in back actions
  defp move_back_to_state(order, state) do
    apply(Order, String.to_atom("move_back_to_#{state}_state"), [order])
  end

  def back(order, state)
  @backable_states "cart"
  def back(%Order{state: "address"} = order, state)  when state in @backable_states, do: move_back_to_state(order, state)
  @backable_states "address"
  def back(%Order{state: "shipping"} = order, state) when state in @backable_states, do: move_back_to_state(order, state)
  @backable_states "shipping"
  def back(%Order{state: "tax"} = order, state)      when state in @backable_states, do: move_back_to_state(order, state)
  @backable_states "tax"
  def back(%Order{state: "payment"} = order, state)  when state in @backable_states, do: move_back_to_state(order, state)

  # default match cannot send the order back because not going to proper state, return the order
  def back(%Order{state: _} = order, _), do: {:ok, order}

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

  def after_transition(%Order{state: "shipping"} = order, _params) do
    order
    |> TaxCalculator.calculate_taxes
  end

  def after_transition(%Order{state: "tax"} = order, _data) do
    order
    |> Order.settle_adjustments_and_product_payments
  end

  def after_transition(%Order{state: "confirmation"} = order, _data) do
    order
    |> Order.acquire_variant_stock
  end

  # default match do nothing just return order
  def after_transition(%Order{} = order, _data), do: order

  defp to_state(%Order{} = order, next_state, params) do
    Nectar.Repo.transaction(fn ->
    {status, model} =
      order
      |> Order.transition_changeset(next_state, params)
      |> before_transition(next_state, params)
      |> Nectar.Repo.update

    case status do
      :ok -> after_transition(model, params)
      :error -> Nectar.Repo.rollback model
    end
    end)
  end

  # TODO: move these methods to gateway
  defp authorize_payment(order, params) do
    # get the selected payment method
    # if none or more than one found return changeset it will handle missing payment method later
    # else use the selected payment_method_id to complete the transaction.
    case params["payment"] do
      %{"payment_method_id" => selected_payment_id} -> do_authorize_payment(order, selected_payment_id, params["payment_method"])
        _  -> order
    end
  end

  defp do_authorize_payment(order, selected_payment_id, payment_method_params) when is_binary(selected_payment_id),
    do: do_authorize_payment(order, String.to_integer(selected_payment_id), payment_method_params)

  defp do_authorize_payment(order, selected_payment_id, payment_method_params) do
    # in case payment fails add the error message to changeset to prevent it from moving to next state.
    case Nectar.Gateway.authorize_payment(order.model, selected_payment_id, payment_method_params) do
      {:ok} -> order
      {:error, error_message} -> order |> Ecto.Changeset.add_error(:payment, error_message)
    end
  end

end
