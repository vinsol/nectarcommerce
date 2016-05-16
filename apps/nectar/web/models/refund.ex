defmodule Nectar.Refund do
  use Nectar.Web, :model

  alias Nectar.Repo
  alias Nectar.LineItemReturn
  alias Nectar.Refund

  schema "refunds" do
    field :amount, :integer

    belongs_to :line_item_return, Nectar.LineItemReturn

    timestamps
  end

  def create_changeset(model, params \\ :empty) do
    model
      |> cast(params, ~w(amount line_item_return_id), ~w())
      |> validate_number(:amount, greater_than: 0)
      |> validate_excess
      |> unique_constraint(:line_item_return_id)
  end

  defp validate_excess(changeset) do
    get_line_item_return_id = changeset.model.line_item_return_id || get_change(changeset, :line_item_return_id)
    get_amount = Decimal.new(get_change(changeset, :amount) || -1)
    get_line_item_return = Repo.get(LineItemReturn, get_line_item_return_id) |> Repo.preload([line_item: [:variant]])
    get_line_item = get_line_item_return.line_item
    refund_amount = Decimal.mult(get_line_item.variant.cost_price, Decimal.new(get_line_item.quantity))
    if Decimal.compare(get_amount, refund_amount) == Decimal.new(1) do
      add_error(changeset, :amount, "Amount should be less than #{refund_amount}")
    else
      changeset
    end
  end
end
