defmodule Nectar.Workflow.AcquireStockFromVariantForOrder do
  def run(repo, order), do: repo.transaction(steps(repo, order))

  alias Ecto.Multi
  def steps(repo, order) do
    order = order |> repo.preload([line_items: :variant])
    Enum.reduce(order.line_items, Multi.new(), fn(line_item, multi_acc) ->
      variant = line_item.variant
      quantity = line_item.quantity
      Multi.append(multi_acc, Nectar.Workflow.AcquireStockFromVariant.steps(variant, quantity))
    end)
  end
end
