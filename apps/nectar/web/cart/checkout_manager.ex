defmodule Nectar.CheckoutManager do

  alias Nectar.Order

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
  def next_changeset(_repo, order, _params), do: order

  def next(repo, %Order{state: state} = order, params) when state in @nextable_state do
    next_module = Map.get(@next_changeset_module, state)
    next_state = Map.get(@state_transitions, state)
    next_module.run(repo, order, Map.merge(params, %{"state" => next_state}))
    |> process_result
  end
  def next(_repo, order, _params), do: order

  def process_result({:ok, changes}), do: {:ok, changes.order}
  def process_result({:error, _name, message, _changes}), do: {:error, message}

  @nextable_states Enum.drop(Enum.reverse(@states), 1)
  def next_state(%Order{state: state}) when state in @nextable_states, do: Map.get(@state_transitions, state)
  def next_state(%Order{state: state}), do: state


  @back_workflows %{
    "cart"     => Nectar.Workflow.MoveBackToCartState,
    "address"  => Nectar.Workflow.MoveBackToAddressState,
    "shipping" => Nectar.Workflow.MoveBackToShippingState,
    "tax"      => Nectar.Workflow.MoveBackToTaxState
  }
  defp move_back_to_state(repo, order, state) do
    module = Map.get(@back_workflows, state)
    module.run(repo, order)
    |> process_back_results
  end

  defp process_back_results({:ok, results}),
    do: {:ok, results.update_state}

  # default back actions
  def back(repo, order)

   # use the workflows here
  def back(repo, %Order{state: "address"} = order),
    do: move_back_to_state(repo, order, "cart")

  def back(repo, %Order{state: "shipping"} = order),
    do: move_back_to_state(repo, order, "address")

  def back(repo, %Order{state: "tax"} = order),
    do: move_back_to_state(repo, order, "shipping")

  # cannot go back from confirmation or cart.
  def back(_repo, %Order{state: _} = order),
    do: {:ok, order}

  Module.register_attribute(__MODULE__, :backable_states, accumulate: true)

  # for jumping multiple steps
  def back(repo, order, state)

  @backable_states "cart"
  def back(repo, %Order{state: "address"} = order, state)  when state in @backable_states,
    do: move_back_to_state(repo, order, state)

  @backable_states "address"
  def back(repo, %Order{state: "shipping"} = order, state) when state in @backable_states,
    do: move_back_to_state(repo, order, state)

  @backable_states "shipping"
  def back(repo, %Order{state: "tax"} = order, state) when state in @backable_states,
    do: move_back_to_state(repo, order, state)

  # default match cannot send the order back because not going to proper state, return the order
  def back(_repo, %Order{state: _} = order, _state),
    do: {:ok, order}

  def view_data(repo, %Order{state: "address"} = order) do
    available_shipping_methods =
      Nectar.Query.ShippingMethod.enabled_shipping_methods(repo)
    order =
      order
      |> repo.preload(:shipment_units)
    %{proposed_shipping_methods: Nectar.ShippingCalculator.calculate_applicable_shippings(order, available_shipping_methods)}
  end

  def view_data(repo, %Order{state: "tax"} = order) do
    %{applicable_payment_methods: Nectar.Invoice.generate_applicable_payment_invoices(repo, order)}
  end

  # TODO: maybe delegate to the respective checkout module. instead
  def view_data(_repo, _order), do: %{}

end
