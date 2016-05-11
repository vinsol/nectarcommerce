defmodule Nectar.ShippingCalculator.Runner do
  use GenServer

  alias Nectar.ShippingCalculator

  @shipping_calculation_timeout 5000 # ms

  defmodule State, do: defstruct order: nil, result: [], timer: nil, caller: nil, pending: [], shipping_methods: []

  def start(caller, [], order), do: {:no_shipping_methods}
  def start(caller, shipping_methods, order) do
    state = %State{caller: caller, shipping_methods: shipping_methods, order: order}
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
    {:noreply, %State{state|timer: timer, pending: proc_list}}
  end

  def handle_info({:ok, results, pid}, state) do
    update_state(state, pid, results)
    |> send_results_if_completed()
  end
  def handle_info({:timeout}, state) do
    # Failure conditions
    # Process Timedout
    send state.caller, {:ok, state.result}
    {:stop, :normal, state}
  end
  def handle_info({:DOWN, _, _, pid, _}, state) do #
    # The process crashed
    # Note: we deregister the monitor on success to avoid multiple calls per process
    update_state(state, pid)
    |> send_results_if_completed()
  end

  def handle_info({:not_applicable, _, pid}, state) do
    # The shipping method is not applicable
    update_state(state, pid)
    |> send_results_if_completed()
  end
  def handle_info({:error, _reason, pid}, state) do
    # Calculator returned an error
    update_state(state, pid)
    |> send_results_if_completed()
  end

  # call on failure
  defp update_state(state, pid) do
    proc_tuple = List.keyfind(state.pending, pid, 0)
    updated_pending = List.delete state.pending, proc_tuple
    %State{state|pending: updated_pending}
  end
  defp update_state(state, pid, result) do
    {pid, monitor} = List.keyfind(state.pending, pid, 0)
    updated_pending = List.delete state.pending, {pid, monitor}
    updated_results = [result|state.result]
    # demonitor to avoid down.
    Process.demonitor(monitor)
    %State{state|pending: updated_pending, result: updated_results}
  end

  defp send_results_if_completed(%State{result: result, timer: timer, caller: caller, pending: []} = updated_state) do
    Process.cancel_timer(timer)
    send caller, {:ok, result}
    # stop the server since all processes have returned
    {:stop, :normal, updated_state}
  end
  defp send_results_if_completed(%State{} = updated_state), do: {:noreply, updated_state}

end
