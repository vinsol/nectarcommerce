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
  test "shipping calculator run with all applicable calculators returns all" do
    order = get_order
    setup_enabled_calculators(@using_calculator)
    proposed_shippings = ShippingCalculator.calculate_applicable_shippings(order) |> Map.get(:shipment_units) |> List.first |> Map.get(:proposed_shipments)
    assert Enum.count(proposed_shippings) == 2
  end

  @using_calculator ["simple", "throws_exception"]
  test "shipping calculator run with one exception throwing calculator returns only success" do
    order = get_order
    setup_enabled_calculators(@using_calculator)
    proposed_shippings = ShippingCalculator.calculate_applicable_shippings(order) |> Map.get(:shipment_units) |> List.first |> Map.get(:proposed_shipments)
    assert Enum.count(proposed_shippings) == 1
    shipping = List.first proposed_shippings
    assert shipping.shipping_method_name == "simple"
    assert shipping.shipping_cost == Decimal.new(0)
  end

  @using_calculator ["simple", "not_applicable", "throws_exception"]
  test "shipping calculator run with one exception throwing and one not applicable calculator returns only success" do
    order = get_order
    setup_enabled_calculators(@using_calculator)
    proposed_shippings = ShippingCalculator.calculate_applicable_shippings(order) |> Map.get(:shipment_units) |> List.first |> Map.get(:proposed_shipments)
    assert Enum.count(proposed_shippings) == 1
    shipping = List.first proposed_shippings
    assert shipping.shipping_method_name == "simple"
    assert shipping.shipping_cost == Decimal.new(0)
  end

  @using_calculator ["simple", "times_out"]
  test "shipping calculator run with one calculator that times out returns only success" do
    order = get_order
    setup_enabled_calculators(@using_calculator)
    proposed_shippings = ShippingCalculator.calculate_applicable_shippings(order) |> Map.get(:shipment_units) |> List.first |> Map.get(:proposed_shipments)
    assert Enum.count(proposed_shippings) == 1
    shipping = List.first proposed_shippings
    assert shipping.shipping_method_name == "simple"
    assert shipping.shipping_cost == Decimal.new(0)
  end

  test "if no calculators are enabled it returns an empty list" do
    order = get_order
    proposed_shippings = ShippingCalculator.calculate_applicable_shippings(order) |> Map.get(:shipment_units) |> List.first |> Map.get(:proposed_shipments)
    assert Enum.count(proposed_shippings) == 0
    assert proposed_shippings == []
  end

  defp create_shipment_units do
    %{variant: variant} = Nectar.TestSetup.Variant.create_variant

    variant =
      variant
      |> Nectar.Variant.changeset(%{add_count: 3})
      |> Repo.update!

    order = Order.cart_changeset(%Order{}, %{}) |> Repo.insert!
    add_to_cart = Nectar.CartManager.add_to_cart(order, %{"variant_id" => variant.id, "quantity" => 3})
    Nectar.Shipment.Splitter.make_shipment_units(Repo.get(Order, order.id))
  end

  defp get_order do
    shipment_units = create_shipment_units
    order = Repo.get(Order, List.first(shipment_units).order_id)
  end

  defp setup_enabled_calculators(calculator_names) do
    Enum.map(calculator_names, fn (name) ->
      ShippingMethod.changeset(%ShippingMethod{}, %{name: name, enabled: true})
      |> Nectar.Repo.insert!
    end)
  end


end
