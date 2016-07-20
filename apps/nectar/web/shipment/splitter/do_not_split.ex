defmodule Nectar.Shipment.Splitter.DoNotSplit do
  alias Nectar.Repo
  alias Nectar.ShipmentUnit

  def split(order) do
    line_items = order.line_items
    [line_items] # only one group of all line items
  end
end
