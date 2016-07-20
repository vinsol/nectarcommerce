defmodule Nectar.Workflow.CreateShipmentUnits do
  alias Ecto.Multi

  def run(repo, order), do: repo.transaction(steps(repo, order))

  def steps(repo, order) do
    Multi.new()
    |> Multi.run(:split_line_items, &(make_shipment_units(&1, repo, order)))
    |> Multi.run(:shipment_units, &(set_shipment_units(&1, repo, order)))
  end

  def make_shipment_units(_changes, repo, order) do
    order = repo.preload(order, [line_items: [variant: :product]])
    {:ok, Nectar.Shipment.Splitter.split(order)}
  end

  def set_shipment_units(changes, repo, order) do
    shipment_units = Enum.map(changes[:split_line_items], fn(line_items) ->
      shipment_unit = Nectar.Command.ShipmentUnit.insert!(repo, %{order_id: order.id})
      Nectar.Command.LineItem.set_shipment_unit(repo, Enum.map(line_items, &(&1.id)), shipment_unit.id)
      shipment_unit
    end)
    {:ok, shipment_units}
  end
end
