defmodule Nectar.ShippingCalculator do
  use GenServer

  alias __MODULE__
  alias Nectar.Order
  alias Nectar.Repo
  alias Nectar.ShippingMethod
  alias Nectar.ShipmentUnit

  # generate all possible shippings
  def calculate_applicable_shippings(%Order{} = order) do
    available_shipping_methods = Repo.all ShippingMethod.enabled_shipping_methods
    # let it crash in any other situation
    order = order |> Repo.preload([:shipment_units])
    case ShippingCalculator.Runner.start(self(), available_shipping_methods, order) do
      {:ok, server} ->
        GenServer.cast(server, {:calculate})
        receive do
          {:ok, results} -> aggregate_into_shipping_units(results)
        end
      {:no_shipping_methods} -> %{}
    end
  end

  def calculate_shipping_cost(%ShippingMethod{} = shipping_method, shipment_unit) do
    # launch the shipping calculator here.
    {status, calculated_shipping_cost} = shipping_cost(shipping_method, shipment_unit)
    result = %{shipping_method_name: shipping_method.name, shipping_cost: calculated_shipping_cost, shipment_unit_id: shipment_unit.id, shipping_method_id: shipping_method.id}
    {status, result}
  end

  defp shipping_calculator_module(method_name) do
    Application.get_env(:nectar, :shipping_calculators)[String.to_atom(method_name)]
  end

  def shipping_cost(%ShippingMethod{name: name}, order) do
    shipping_calculator_module(name).calculate_shipping(order)
  end

  def aggregate_into_shipping_units(results) do
    grouped_results = Enum.group_by(results, &(&1.shipment_unit_id))
  end

end
