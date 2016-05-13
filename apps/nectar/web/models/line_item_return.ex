defmodule Nectar.LineItemReturn do
  use Nectar.Web, :model

  @status_map %{"pending" => 0, "returned" => 1, "discarded" => 2}
  @reverse_status_map %{0 => "pending", 1 => "returned", 2 => "discarded"}

  def status_map do
    @status_map
  end

  def get_status(name) do
    Map.fetch!(status_map, name)
  end

  def reverse_status_map do
    @reverse_status_map
  end

  schema "line_item_returns" do
    field :quantity, :integer
    field :status, :integer
    belongs_to :line_item, Nectar.LineItem

    timestamps
  end

  @required_fields ~w(quantity status line_item_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def updated_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(status), ~w())
  end

  def stock_and_order_update(line_item_return, params \\ :empty) do
    changeset = line_item_return
      |> updated_changeset(params)
    do_stock_and_order_update(line_item_return, changeset)
  end

  # Pattern match on changeset for changes
  defp do_stock_and_order_update(%Nectar.LineItemReturn{status: 1} = line_item_return, changeset) do
    Nectar.Repo.transaction(fn ->
      case Repo.update(changeset) do
        {:ok, line_item_return}->
          # An extra query as not assuming coming preloaded from above
          line_item_return = line_item_return |> Repo.preload(:line_item)
          line_item = line_item_return.line_item
          LineItem.restock_variant(line_item)
          Order.settle_adjustments_and_product_payments(line_item.order)
        {:error, changeset} ->
          Nectar.Repo.rollback changeset
      end
    end)
  end
  defp do_stock_and_order_update(%Nectar.LineItemReturn{status: 2} = line_item_return, changeset), do: {:ok, line_item_return}
  defp do_stock_and_order_update(line_item_return, changeset), do: {:error, Ecto.Changeset.add_error(change(line_item_return, %{}), :status, "not given")}
end
