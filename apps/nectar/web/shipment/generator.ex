defmodule Nectar.Shipment.Generator do
  alias Nectar.ShippingCalculator

  def propose(order) do
    ShippingCalculator.calculate_applicable_shippings(order)
  end

end
