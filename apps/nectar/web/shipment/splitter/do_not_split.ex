defmodule Nectar.Shipment.Splitter.DoNotSplit do
  def split(order) do
    line_items = order.line_items
    [line_items] # only one group of all line items
  end
end
