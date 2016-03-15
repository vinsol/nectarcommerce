defmodule Nectar.ShippingCalculator do
  alias Nectar.Order
  alias Nectar.Repo

  # generate all possible shippings
  def calculate_applicable_shippings(%Order{} = order) do
    # replace with a distributed worker/async approach
    # collect all available results avoid awaiting for all
    # see: http://theerlangelist.com/article/beyond_taskasync for reference
    Enum.map(Repo.all(Nectar.ShippingMethod.enabled_shipping_methods), fn (shipping_method) -> calculate_shipping_cost(shipping_method, order) end)
  end

  def calculate_shipping_cost(shipping_method, order) do
    # launch the shipping calculator here.
    Map.from_struct(%Nectar.ShippingMethod{shipping_method|shipping_cost: shipping_cost(shipping_method, order)})
    |> Map.drop([:__meta__, :shippings])
  end

  def shipping_cost(_method, _order) do
    # link this with ETS to allow quick look up once done.
    # will be dispatched to the corresponding worker which either calculates it
    # or returns with a quick lookup
    Decimal.new(10)
  end
end
