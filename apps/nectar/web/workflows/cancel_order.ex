defmodule Nectar.Workflow.CancelOrder do
  alias Ecto.Multi

  def run(repo, order), do: repo.transaction(steps(repo, order))

  def steps(repo, order) do
    Multi.new()
    |> Multi.run(:cancel_line_item_fulfillment, &(cancel_line_order_fullfillment(&1, repo, order)))
  end

  def cancel_line_order_fullfillment(_changes, repo, order) do
    line_items = order |> repo.preload([:line_items]) |> Map.get(:line_items)
    # Stream over the cancel fullfilment workflow and revert if one fails
  end

end
