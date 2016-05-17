defmodule Nectar.Shipment.Splitter.DoNotSplit do
  alias Nectar.Repo
  alias Nectar.ShipmentUnit

  def split(order) do
    line_items = order |> Repo.preload([:line_items]) |> Map.get(:line_items)
    ShipmentUnit.create(line_items)
  end
end
