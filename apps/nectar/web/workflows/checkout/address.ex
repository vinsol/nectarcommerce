defmodule Nectar.Workflow.Checkout.Address do
  alias Ecto.Multi

  def run(repo, order, params),
    do: repo.transaction(steps(repo, order, params))

  def order_with_preloads(repo, order) do
    order
    |> repo.preload([:order_shipping_address, :order_billing_address,
                    :line_items, :shipping_address, :billing_address])
  end

  def changeset_for_step(order, params \\ %{}) do
    Nectar.Order.address_changeset(order, params)
  end

  def steps(repo, order, params) do
    order = order_with_preloads(repo, order)
    changeset = changeset_for_step(order, params)
    Multi.new()
    |> Multi.append(pre_transition(repo, changeset))
    |> Multi.update(:order, changeset)
    |> Multi.run(:post, &(post_transition(repo, &1)))
  end

  def view_data(_, _), do: %{}

  defp pre_transition(repo, order_changeset) do
    Multi.new()
    |> Multi.run(:line_item_check, &(has_line_items(&1, order_changeset)))
    |> Multi.append(Nectar.Workflow.ConfirmAvailabilityInOrderChangeset.steps(repo, order_changeset))
  end

  defp has_line_items(_changes, order_changeset) do
    if Enum.count(order_changeset.data.line_items) == 0 do
      {:error, Ecto.Changeset.add_error(order_changeset, :line_items, "Please add some item to your cart to proceed")}
    else
      {:ok, order_changeset}
    end
  end

  defp post_transition(repo, changes) do
    Multi.new()
    |> Multi.append(Nectar.Workflow.CreateShipmentUnits.steps(repo, changes.order))
    |> repo.transaction
  end
end
