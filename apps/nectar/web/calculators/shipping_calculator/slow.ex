defmodule Nectar.ShippingCalculator.Slow do
  use Nectar.ShippingCalculator.Base, shipping_rate: 2

  def applicable?(_order) do
    false
  end
end
