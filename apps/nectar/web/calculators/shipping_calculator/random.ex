defmodule Nectar.ShippingCalculator.Random do
  use Nectar.ShippingCalculator.Base

  def shipping_rate(_order) do
    :random.seed(:os.timestamp)
    Decimal.new(:random.uniform(200))
  end
end
