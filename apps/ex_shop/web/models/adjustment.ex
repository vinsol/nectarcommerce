defmodule ExShop.Adjustment do
  use ExShop.Web, :model

  schema "adjustments" do
    belongs_to :shipping, ExShop.Shipping
    belongs_to :tax,      ExShop.Tax
    belongs_to :order,    ExShop.Order

    field :amount, :decimal

    timestamps
  end

  @required_fields ~w(amount)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
