defmodule NectarWallet.Wallet do
  use NectarWallet.Web, :model

  @zero_amount Decimal.new(0)
  schema "wallets" do
    field :amount, :decimal, default: @zero_amount
    field :add_amount, :decimal, virtual: true, default: @zero_amount
    field :deduct_amount, :decimal, virtual: true, default: @zero_amount
    belongs_to :user, NectarWallet.User

    timestamps
  end

  @required_fields ~w(user_id)
  @optional_fields ~w(amount)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def add_points_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(add_amount), ~w())
    |> validate_number(:add_amount, greater_than: @zero_amount)
    |> add_amount_change
  end

  def deduction_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(deduct_amount), ~w())
    |> validate_number(:deduct_amount, greater_than_or_equal_to: @zero_amount)
    |> validate_number(:deduct_amount, less_than: model.amount)
    |> deduct_amount_change
  end

  defp add_amount_change(%Ecto.Changeset{valid?: true} = changeset) do
    amount_to_add = changeset.changes[:add_amount]
    if amount_to_add do
      existing_amount = changeset.model.amount
      put_change(changeset, :amount, Decimal.add(amount_to_add, existing_amount))
    else
      changeset
    end
  end
  defp add_amount_change(%Ecto.Changeset{} = changeset), do: changeset

  defp deduct_amount_change(%Ecto.Changeset{valid?: true} = changeset) do
    amount_to_deduct = changeset.changes[:deduct_amount]
    if amount_to_deduct do
      existing_amount = changeset.model.amount
      put_change(changeset, :amount, Decimal.sub(existing_amount, amount_to_deduct))
    else
      changeset
    end
  end
  defp deduct_amount_change(%Ecto.Changeset{} = changeset), do: changeset

end
