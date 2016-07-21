defmodule Nectar.Shipment.Splitter.SplitAll do
  def split(order) do
    Enum.map(order.line_items, fn(line_item) -> [line_item] end)
  end
end
