defmodule Nectar.ShippingCalculatorTest do
  use Nectar.ModelCase

  alias Nectar.ShippingCalculator
  alias Nectar.ShippingCalculator.Base
  import Nectar.TestSetup.ShippingMethod, only: [create_shipping_methods: 1]
  import Nectar.TestSetup.ShipmentUnit, only: [create_shipment_units: 0]
  import Nectar.TestSetup.Order, only: [order_with_shipment_units: 0]

  defmodule Simple do
    use Base
  end

  defmodule ProvidedShippingRate do
    use Base, shipping_rate: 12
  end

  defmodule OveriddenShippingRate do
    use Base

    def shipping_rate(_shipping_unit) do
      Decimal.new(100)
    end
  end

  defmodule ThrowsException do
    use Base

    def shipping_rate(_shipping_unit) do
      1/0
    end
  end

  defmodule TimesOut do
    use Base

    def shipping_rate(_shipping_unit) do
      :timer.sleep(6000)
      Decimal.new(0)
    end
  end

  defmodule NotApplicable do
    use Base

    def applicable?(_shipping_unit) do
      false
    end
  end

  test "default calculator implementation" do
    shipment_units = create_shipment_units
    assert Simple.applicable?(shipment_units) == true
    assert Simple.shipping_rate(shipment_units) == Decimal.new(0)
    assert Simple.calculate_shipping(shipment_units) == {:ok, Decimal.new(0)}
  end

  test "calculator implementation with provided shipping rate" do
    shipment_units = create_shipment_units
    assert ProvidedShippingRate.applicable?(shipment_units) == true
    assert ProvidedShippingRate.shipping_rate(shipment_units) == Decimal.new(12)
    assert ProvidedShippingRate.calculate_shipping(shipment_units) == {:ok, Decimal.new(12)}

  end

  test "calculator implmentation with overriden shipping_rate method" do
    shipment_units = create_shipment_units
    assert OveriddenShippingRate.applicable?(shipment_units) == true
    assert OveriddenShippingRate.shipping_rate(shipment_units) == Decimal.new(100)
    assert OveriddenShippingRate.calculate_shipping(shipment_units) == {:ok, Decimal.new(100)}
  end

  test "calculator implementation with overriden applicable? method" do
    shipment_units = create_shipment_units
    assert NotApplicable.applicable?(shipment_units) == false
    assert NotApplicable.calculate_shipping(shipment_units) == {:not_applicable, Decimal.new(0)}
  end

  @using_calculator ["simple", "provided"]
  test "shipping calculator run with all applicable calculators returns all with one entry per shipment unit" do
    create_shipping_methods(@using_calculator)
    assert Enum.count(proposed_shipments(order_with_shipment_units)) == 2
  end

  @using_calculator ["simple", "throws_exception"]
  test "shipping calculator run with one exception throwing calculator returns only success" do
    create_shipping_methods(@using_calculator)
    proposed_shippings = proposed_shipments(order_with_shipment_units)
    assert Enum.count(proposed_shippings) == 1
    shipping = List.first proposed_shippings
    assert shipping.shipping_method_name == "simple"
    assert shipping.shipping_cost == Decimal.new(0)
  end

  @using_calculator ["simple", "not_applicable", "throws_exception"]
  test "shipping calculator run with one exception throwing and one not applicable calculator returns only success" do
    create_shipping_methods(@using_calculator)
    proposed_shippings = proposed_shipments(order_with_shipment_units)
    assert Enum.count(proposed_shippings) == 1
    shipping = List.first proposed_shippings
    assert shipping.shipping_method_name == "simple"
    assert shipping.shipping_cost == Decimal.new(0)
  end

  @using_calculator ["simple", "times_out"]
  test "shipping calculator run with one calculator that times out returns only success" do
    create_shipping_methods(@using_calculator)
    proposed_shippings = proposed_shipments(order_with_shipment_units)
    assert Enum.count(proposed_shippings) == 1
    shipping = List.first proposed_shippings
    assert shipping.shipping_method_name == "simple"
    assert shipping.shipping_cost == Decimal.new(0)
  end

  test "if no calculators are enabled it returns an empty list" do
    proposed_shippings = proposed_shipments(order_with_shipment_units)
    assert Enum.count(proposed_shippings) == 0
    assert proposed_shippings == []
  end

  def proposed_shipments(order) do
    order = order |> Repo.preload([:shipment_units])
    shipment_unit = List.first(order.shipment_units)
    applicable_shipping_methods = Nectar.Query.ShippingMethod.enabled_shipping_methods(Nectar.Repo)
    results = ShippingCalculator.calculate_applicable_shippings(order, applicable_shipping_methods)
    results |> Map.get(shipment_unit.id, [])
  end

end
