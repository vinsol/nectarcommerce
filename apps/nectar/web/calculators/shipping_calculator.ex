defmodule Nectar.ShippingCalculator do
  use GenServer

  alias __MODULE__
  alias Nectar.Repo
  alias Nectar.ShippingMethod
  alias Nectar.Order
  alias Nectar.Repo

  # hold the state in this struct
  defstruct order: nil, result: [], timer: nil, caller: nil, pending: [], shipping_methods: []

  @shipping_calculation_timeout 5000 # ms

  # generate all possible shippings
  def calculate_applicable_shippings(%Order{} = order) do
    available_shipping_methods = Repo.all ShippingMethod.enabled_shipping_methods
    {:ok, server} = ShippingCalculator.start(self(), available_shipping_methods, order)
    GenServer.cast(server, {:calculate})
    applicable_shippings = receive do
      {:ok, results} -> results
    end
    applicable_shippings
  end

  def calculate_shipping_cost(%ShippingMethod{} = shipping_method, order) do
    # launch the shipping calculator here.
    {status, calculated_shipping_cost} = shipping_cost(shipping_method, order)
    cost = Map.from_struct(%ShippingMethod{shipping_method|shipping_cost: calculated_shipping_cost})
    |> Map.drop([:__meta__, :shippings, :inserted_at, :updated_at])
    {status, cost}
  end

  defp shipping_calculator_module(method_name) do
    Application.get_env(:shipping_calculators, String.to_atom(method_name))
  end

  def shipping_cost(%ShippingMethod{name: name}, order) do
    shipping_calculator_module(name).calculate_shipping(order)
  end

  #### Genserver Methods Start Here ####

  def start(caller, shipping_methods, order) do
    state = %ShippingCalculator{caller: caller, shipping_methods: shipping_methods, order: order}
    GenServer.start(__MODULE__, state, [])
  end

  def handle_cast({:calculate}, state) do
    current = self()
    proc_list = Enum.map(state.shipping_methods, fn(method) ->
      spawn_monitor(fn ->
        send(current, Tuple.append(ShippingCalculator.calculate_shipping_cost(method, state.order), self()))
      end)
    end)
    timer = Process.send_after(current, {:timeout}, @shipping_calculation_timeout)
    {:noreply, %ShippingCalculator{state|timer: timer, pending: proc_list}}
  end

  def handle_info({:ok, results, pid}, state) do
    update_state(state, pid, results)
    |> send_results_if_completed()
  end

  # Failure conditions
  # Process Timedout
  def handle_info({:timeout}, state) do
    send state.caller, {:ok, state.result}
    {:stop, :normal, state}
  end

  # The process crashed
  # Note: we deregister the monitor on success to avoid multiple calls per process
  def handle_info({:DOWN, _, _, pid, _}, state) do #
    update_state(state, pid)
    |> send_results_if_completed()
  end

  # The shipping method is not applicable
  def handle_info({:not_applicable, _, pid}, state) do
    update_state(state, pid)
    |> send_results_if_completed()
  end

  # Calculator returned an error
  def handle_info({:error, _reason, pid}, state) do
    update_state(state, pid)
    |> send_results_if_completed()
  end

  # call on failure
  defp update_state(state, pid) do
    proc_tuple = List.keyfind(state.pending, pid, 0)
    updated_pending = List.delete state.pending, proc_tuple
    %ShippingCalculator{state|pending: updated_pending}
  end

  # call on success with results
  defp update_state(state, pid, result) do
    {pid, monitor} = List.keyfind(state.pending, pid, 0)
    updated_pending = List.delete state.pending, {pid, monitor}
    updated_results = [result|state.result]
    # demonitor to avoid down.
    Process.demonitor(monitor)
    %ShippingCalculator{state|pending: updated_pending, result: updated_results}
  end

  defp send_results_if_completed(%ShippingCalculator{result: result, timer: timer, caller: caller, pending: []} = updated_state) do
    Process.cancel_timer(timer)
    send caller, {:ok, result}
    # stop the server since all processes have returned
    {:stop, :normal, updated_state}
  end
  defp send_results_if_completed(%ShippingCalculator{} = updated_state), do: {:noreply, updated_state}

end
