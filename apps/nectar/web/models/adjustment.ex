defmodule Nectar.Adjustment do
  use Nectar.Web, :model

  schema "adjustments" do
    belongs_to :shipment, Nectar.Shipment
    belongs_to :tax,      Nectar.Tax
    belongs_to :order,    Nectar.Order

    field :amount, :decimal

    timestamps
    extensions
  end

  @required_fields ~w(amount)
  @optional_fields ~w(shipment_id tax_id order_id)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def for_order(%Nectar.Order{id: order_id}) do
    from p in Nectar.Adjustment,
    where: p.order_id == ^order_id
  end

end
