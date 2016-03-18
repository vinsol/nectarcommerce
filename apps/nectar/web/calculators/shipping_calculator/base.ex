defmodule Nectar.ShippingCalculator.Base do
  @callback calculate_shipping(Nectar.Order.t) :: any
  @callback applicable?(Nectar.Order.t) :: any
  @callback shipping_rate(Nectar.Order.t) :: any

  defmacro __using__([shipping_rate: provided_shipping_rate]) do
    add_shipping_methods(provided_shipping_rate)
  end

  defmacro __using__(_) do
    add_shipping_methods("0")
  end

  def add_shipping_methods(shipping) do
    quote location: :keep do

      @behaviour Nectar.ShippingCalculator.Base
      def calculate_shipping(order) do
        if applicable? order do
          {:ok, shipping_rate(order)}
        else
          {:not_applicable, Decimal.new("0")}
        end
      end

      def applicable?(order) do
        true
      end

      def shipping_rate(order) do
        Decimal.new(unquote(shipping))
      end

      defoverridable [calculate_shipping: 1, applicable?: 1, shipping_rate: 1]
    end
  end

end
