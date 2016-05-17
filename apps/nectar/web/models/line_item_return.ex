defmodule Nectar.LineItemReturn do
  use Nectar.Web, :model

  alias Nectar.Repo
  alias Nectar.LineItem
  alias Nectar.Order

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

  def get_human_status(name) do
    Map.fetch!(reverse_status_map, name)
  end

  def is_pending?(status) do
    status == 0
  end

  def is_accepted?(status) do
    (status == 1) || (status == 2)
  end

  schema "line_item_returns" do
    field :quantity, :integer
    field :status, :integer
    belongs_to :line_item, Nectar.LineItem

    has_one :refund, Nectar.Refund

    timestamps
    extensions
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

  def accept_or_reject(line_item_return, params \\ :empty)
  def accept_or_reject(%Nectar.LineItemReturn{status: 0} = line_item_return, params) do
    changeset = line_item_return
      |> updated_changeset(params)
    do_stock_update(line_item_return, changeset)
  end
  def accept_or_reject(line_item_return, params), do: {:noop, line_item_return}

  # Pattern match on changeset for changes
  defp do_stock_update(line_item_return, %Ecto.Changeset{changes: %{status: 1}} = changeset) do
    Repo.transaction(fn ->
      case Repo.update(changeset) do
        {:ok, line_item_return}->
          # An extra query as not assuming coming preloaded from above
          line_item_return = line_item_return |> Repo.preload([line_item: [:variant, [order: :adjustments]]])
          line_item = line_item_return.line_item
          LineItem.restock_variant(line_item)
        {:error, changeset} ->
          Repo.rollback changeset
      end
    end)
  end
  defp do_stock_update(line_item_return, %Ecto.Changeset{changes: %{status: 2}} = changeset), do: Repo.update(changeset)
  defp do_stock_update(line_item_return, changeset), do: {:noop, line_item_return}
end
