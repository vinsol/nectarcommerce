defmodule Nectar.Shipping do
  use Nectar.Web, :model

  schema "shippings" do
    belongs_to :order, Nectar.Order
    belongs_to :shipping_method, Nectar.ShippingMethod
    has_one :adjustment, Nectar.Adjustment

    timestamps
  end

  @required_fields ~w(shipping_method_id)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def applicable_shipping_changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> cast_assoc(:adjustment)
    |> foreign_key_constraint(:shipping_method_id)
  end

  def for_order(%Nectar.Order{id: order_id}) do
    from p in Nectar.Shipping,
    where: p.order_id == ^order_id
  end

end
