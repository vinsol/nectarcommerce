defmodule Nectar.ShippingCalculator do
  use GenServer

  alias __MODULE__
  alias Nectar.Order
  alias Nectar.Repo
  alias Nectar.ShippingMethod

  # generate all possible shippings
  def calculate_applicable_shippings(%Order{} = order) do
    available_shipping_methods = Repo.all ShippingMethod.enabled_shipping_methods
    {:ok, server} = ShippingCalculator.Runner.start(self(), available_shipping_methods, order)
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
    Application.get_env(:nectar, :shipping_calculators)[String.to_atom(method_name)]
  end

  def shipping_cost(%ShippingMethod{name: name}, order) do
    shipping_calculator_module(name).calculate_shipping(order)
  end

end
