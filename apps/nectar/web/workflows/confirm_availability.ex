defmodule Nectar.Workflow.ConfirmAvailabilityInOrderChangeset do
  alias Ecto.Multi

  @doc """
  Takes a changeset as input.
  """
  def run(repo, order_changeset),
    do: repo.transaction(steps(repo, order_changeset))

  def steps(repo, order_changeset) do
    Multi.new()
    |> Multi.run(:confirm_availability, &(confirm_availability_of_line_items(&1, repo, order_changeset)))
  end

  defp confirm_availability_of_line_items(_changes, repo, order_changeset) do
    order = order_changeset.data |> repo.preload([line_items: [variant: :product]])
    {available, oos, discontinued, insufficient} = Nectar.Order.check_line_items_for_availability(order)
    if available do
      {:ok, order_changeset}
    else
      changeset =
        order_changeset
        |> add_error_message(:out_of_stock, oos)
        |> add_error_message(:discontinued, discontinued)
        |> add_error_message(:insuffcient_quantity, insufficient)

      {:error, changeset}
    end
  end

  defp add_error_message(changeset, _type, []), do: changeset

  defp add_error_message(changeset, :out_of_stock, oos) do
    Enum.reduce(oos, changeset, fn(line_item, changeset_acc) ->
      variant_display_name = Nectar.Variant.display_name(line_item.variant)
      msg = "#{ variant_display_name } is out of stock"
      Ecto.Changeset.add_error(changeset_acc, :line_items, msg)
    end)
  end

  defp add_error_message(changeset, :discontinued, discontinued) do
    Enum.reduce(discontinued, changeset, fn(line_item, changeset_acc) ->
      variant_display_name = Nectar.Variant.display_name(line_item.variant)
      msg = "#{ variant_display_name } is discontinued"
      Ecto.Changeset.add_error(changeset_acc, :line_items, msg)
    end)
  end

  defp add_error_message(changeset, :insuffcient_quantity, insuff) do
    Enum.reduce(insuff, changeset, fn({line_item, available}, changeset_acc) ->
      variant_display_name = Nectar.Variant.display_name(line_item.variant)
      msg = "#{ variant_display_name } is not available in the requested quantity. Only #{ available } available"
      Ecto.Changeset.add_error(changeset_acc, :line_items, msg)
    end)
  end

end
