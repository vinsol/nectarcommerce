defmodule Nectar.CheckoutManager do

  alias Nectar.Order
  alias Nectar.TaxCalculator
  alias Nectar.Shipment.Splitter

  # States:
  # cart -> address -> shipping -> tax -> payment -> confirmation
  @states ~w(cart address shipping tax payment confirmation)
  @state_transitions @states
                     |> Enum.zip(Enum.drop(@states, 1))
                     |> Enum.reduce(%{}, fn ({frm, to}, acc) -> Map.put_new(acc, frm, to) end)

  @next_changeset_module %{
    "cart"     => Nectar.Workflow.Checkout.Address,
    "address"  => Nectar.Workflow.Checkout.Shipping,
    "shipping" => Nectar.Workflow.Checkout.Tax,
    "tax"      => Nectar.Workflow.Checkout.Payment
  }
  @nextable_state Map.keys(@next_changeset_module)

  def next_changeset(repo, order, params \\ %{})

  def next_changeset(repo, %Order{state: state} = order, params) when state in @nextable_state do
    next_module = Map.get(@next_changeset_module, state)
    order = next_module.order_with_preloads(repo, order)
    next_module.changeset_for_step(order, params)
  end
  def next_changeset(_repo, order, params), do: order

  def next(repo, %Order{state: state} = order, params) when state in @nextable_state do
    next_module = Map.get(@next_changeset_module, state)
    next_state = Map.get(@state_transitions, state)
    next_module.run(repo, order, Map.merge(params, %{"state" => next_state}))
    |> process_result
  end
  def next(repo, order, params), do: order

  def process_result({:ok, changes}), do: {:ok, changes.order}
  def process_result({:error, _name, message, _changes}), do: {:error, message}

  @nextable_states Enum.drop(Enum.reverse(@states), 1)
  def next_state(%Order{state: state}) when state in @nextable_states, do: Map.get(@state_transitions, state)
  def next_state(%Order{state: state}), do: state

  def back(order)

  # use the workflows here
  def back(%Order{state: "address"} = order),  do: Order.move_back_to_cart_state(order)
  def back(%Order{state: "shipping"} = order), do: Order.move_back_to_address_state(order)
  def back(%Order{state: "tax"} = order),      do: Order.move_back_to_shipping_state(order)

  # cannot go back from confirmation or cart.
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

  # default match cannot send the order back because not going to proper state, return the order
  def back(%Order{state: _} = order, _), do: {:ok, order}

  # TODO: delegate to the module.
  def view_data(order), do: %{}

end
