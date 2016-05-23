defmodule Nectar.Shipment.Splitter do

  alias Nectar.Shipment.Splitter.DoNotSplit

  def make_shipment_units(order) do
    shipment_splitter = configured_shipment_splitter || DoNotSplit
    shipment_splitter.split(order)
  end

  defp configured_shipment_splitter do
    Application.get_env(:nectar, :shipment_splitter)
  end

end
