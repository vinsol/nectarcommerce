defmodule Nectar.Workflow.CancelOrder do
  alias Ecto.Multi

  def run(repo, order), do: repo.transaction(steps(repo, order))

  def steps(repo, order) do
    Multi.new()
    |> Multi.run(:cancel_line_item_fulfillment, &(cancel_line_order_fullfillment(&1, repo, order)))
  end

  def cancel_line_order_fullfillment(_changes, repo, order) do
    line_items = order |> repo.preload([:line_items]) |> Map.get(:line_items)
    # Stream over the cancel fullfilment workflow, cancel when the first one fails.
    line_item_cancellations = Stream.map(line_items, &(Nectar.Workflow.CancelLineItemFullfillment.run(repo, &1)))

    all_cancelled = Enum.all?(line_item_cancellations, fn
      ({:error, _}) -> false
      (_) -> true
    end)

    if not all_cancelled do
      {:error, "Failed to cancel the order"}
    else
      {:ok, "Order cancelled successfully"}
    end
  end

end
