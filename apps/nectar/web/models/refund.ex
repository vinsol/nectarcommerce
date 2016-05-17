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
      |> validate_line_item_return
      |> unique_constraint(:line_item_return_id)
  end

  defp validate_line_item_return(changeset) do
    get_line_item_return_id = changeset.model.line_item_return_id || get_change(changeset, :line_item_return_id)
    # check, if it can be made pretty using *with*
    if get_line_item_return_id do
      get_line_item_return = Repo.get(LineItemReturn, get_line_item_return_id)
      if get_line_item_return do
        line_item_return = get_line_item_return |> Repo.preload([line_item: [:variant]])
        changeset
          |> validate_return_status(line_item_return)
          |> validate_excess(line_item_return)
      else
        add_error(changeset, :line_item_return_id, "not valid")
      end
    else
      add_error(changeset, :line_item_return_id, "Missing line_item_return_id")
    end
  end

  defp validate_return_status(changeset, line_item_return) do
    if Nectar.LineItemReturn.is_accepted?(line_item_return.status) do
      changeset
    else
      add_error(changeset, :line_item_return_id, "should be either returned or discarded")
    end
  end

  defp validate_excess(changeset, line_item_return) do
    get_amount = Decimal.new(get_change(changeset, :amount) || -1)
    get_line_item = line_item_return.line_item
    refund_amount = Decimal.mult(get_line_item.variant.cost_price, Decimal.new(get_line_item.quantity))
    if Decimal.compare(get_amount, refund_amount) == Decimal.new(1) do
      add_error(changeset, :amount, "Amount should be less than #{refund_amount}")
    else
      changeset
    end
  end
end
