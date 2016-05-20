defmodule Nectar.Shipment.Generator do
  alias Nectar.Repo
  alias Nectar.ShippingMethod
  alias Nectar.Shipment.Splitter
  alias Nectar.ShippingCalculator


  def propose(order) do
    ShippingCalculator.calculate_applicable_shippings(order)
  end
  # Shipment Params:
  # {shipment_unit => shipment_method_id}
  # Ouput:
  # shipments <=> shipment_units <=> line_items
  def generate_shipments(order, shipment_params) do
  end


end
