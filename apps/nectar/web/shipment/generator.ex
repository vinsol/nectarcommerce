defmodule Nectar.Shipment.Generator do
  alias Nectar.Repo
  alias Nectar.ShippingMethod
  alias Nectar.Shipment.Splitter

  def propose_shipments(order, shipping_methods) do
    Shipment.Splitter.make_shipment_units(order)
    |> Nectar.ShippingCalculator.calculate_applicable_shippings(order)
  end

  # Shipment Params:
  # {shipment_unit => shipment_method_id}
  # Ouput:
  # shipments <=> shipment_units <=> line_items
  def generate_shipments(order, shipment_params) do
  end


end
