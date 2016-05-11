defmodule Nectar.ShippingCalculatorTest do
  use Nectar.ModelCase

  alias Nectar.Order
  alias Nectar.ShippingCalculator
  alias Nectar.ShippingCalculator.Base
  alias Nectar.ShippingMethod

  defmodule Simple do
    use Base
  end

  defmodule ProvidedShippingRate do
    use Base, shipping_rate: 12
  end

  defmodule OveriddenShippingRate do
    use Base

    def shipping_rate(order) do
      Decimal.new(100)
    end
  end

  defmodule ThrowsException do
    use Base

    def shipping_rate(order) do
      1/0
    end
  end

  defmodule TimesOut do
    use Base

    def shipping_rate(order) do
      :timer.sleep(6000)
      Decimal.new(0)
    end
  end

  defmodule NotApplicable do
    use Base

    def applicable?(order) do
      false
    end
  end

  test "default calculator implementation" do
    order = create_order
    assert Simple.applicable?(order) == true
    assert Simple.shipping_rate(order) == Decimal.new(0)
    assert Simple.calculate_shipping(order) == {:ok, Decimal.new(0)}
  end

  test "calculator implementation with provided shipping rate" do
    order = create_order
    assert ProvidedShippingRate.applicable?(order) == true
    assert ProvidedShippingRate.shipping_rate(order) == Decimal.new(12)
    assert ProvidedShippingRate.calculate_shipping(order) == {:ok, Decimal.new(12)}

  end

  test "calculator implmentation with overriden shipping_rate method" do
    order = create_order
    assert OveriddenShippingRate.applicable?(order) == true
    assert OveriddenShippingRate.shipping_rate(order) == Decimal.new(100)
    assert OveriddenShippingRate.calculate_shipping(order) == {:ok, Decimal.new(100)}
  end

  test "calculator implementation with overriden applicable? method" do
    order = create_order
    assert NotApplicable.applicable?(order) == false
    assert NotApplicable.calculate_shipping(order) == {:not_applicable, Decimal.new(0)}
  end

  @using_calculator ["simple", "provided"]
  test "shipping calculator run with all applicable calculators returns all" do
    setup_enabled_calculators(@using_calculator)
    calculated_shippings = ShippingCalculator.calculate_applicable_shippings(create_order)
    assert Enum.count(calculated_shippings) == 2
  end

  @using_calculator ["simple", "throws_exception"]
  test "shipping calculator run with one exception throwing calculator returns only success" do
    setup_enabled_calculators(@using_calculator)
    calculated_shippings = ShippingCalculator.calculate_applicable_shippings(create_order)
    assert Enum.count(calculated_shippings) == 1
    shipping = List.first calculated_shippings
    assert shipping.name == "simple"
    assert shipping.shipping_cost == Decimal.new(0)
  end

  @using_calculator ["simple", "not_applicable", "throws_exception"]
  test "shipping calculator run with one exception throwing and one not applicable calculator returns only success" do
    setup_enabled_calculators(@using_calculator)
    calculated_shippings = ShippingCalculator.calculate_applicable_shippings(create_order)
    assert Enum.count(calculated_shippings) == 1
    shipping = List.first calculated_shippings
    assert shipping.name == "simple"
    assert shipping.shipping_cost == Decimal.new(0)
  end

  @using_calculator ["simple", "times_out"]
  test "shipping calculator run with one calculator that times out returns only success" do
    setup_enabled_calculators(@using_calculator)
    calculated_shippings = ShippingCalculator.calculate_applicable_shippings(create_order)
    assert Enum.count(calculated_shippings) == 1
    shipping = List.first calculated_shippings
    assert shipping.name == "simple"
    assert shipping.shipping_cost == Decimal.new(0)
  end

  test "if no calculators are enabled it returns an empty list" do
    calculated_shippings = ShippingCalculator.calculate_applicable_shippings(create_order)
    assert Enum.count(calculated_shippings) == 0
    assert calculated_shippings == []
  end

  defp create_order do
    Order.cart_changeset(%Order{}, %{})
    |> Repo.insert!
  end

  defp setup_enabled_calculators(calculator_names) do
    Enum.map(calculator_names, fn (name) ->
      ShippingMethod.changeset(%ShippingMethod{}, %{name: name, enabled: true})
      |> Nectar.Repo.insert!
    end)
  end


end
