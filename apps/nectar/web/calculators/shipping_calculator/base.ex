defmodule Nectar.ShippingCalculator.Base do
  @callback calculate_shipping(Nectar.ShippingUnit.t) :: any
  @callback applicable?(Nectar.ShippingUnit.t) :: any
  @callback shipping_rate(Nectar.ShippingUnit.t) :: any

  defmacro __using__([shipping_rate: provided_shipping_rate]) do
    add_shipping_methods(provided_shipping_rate)
  end

  defmacro __using__(_) do
    add_shipping_methods(0)
  end

  def add_shipping_methods(shipping) do
    quote location: :keep do

      @behaviour Nectar.ShippingCalculator.Base
      def calculate_shipping(shipping_unit) do
        if applicable? shipping_unit do
          {:ok, shipping_rate(shipping_unit)}
        else
          {:not_applicable, Decimal.new(0)}
        end
      end

      def applicable?(shipping_unit) do
        true
      end

      def shipping_rate(shipping_unit) do
        Decimal.new(unquote(shipping))
      end

      defoverridable [calculate_shipping: 1, applicable?: 1, shipping_rate: 1]
    end
  end

end
