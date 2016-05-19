defmodule Nectar.Shipment.Splitter.SplitAll do
  alias Nectar.Repo
  alias Nectar.ShipmentUnit

  def split(order) do
    order = order |> Repo.preload([:line_items])
    Enum.map(order.line_items, fn (ln_it) -> ShipmentUnit.create [ln_it] end)
  end
end
