defmodule ExShop.Shipping do
  use ExShop.Web, :model

  schema "shippings" do
    belongs_to :order, ExShop.Order
    belongs_to :shipping_method, ExShop.ShippingMethod
    has_one :adjustment, ExShop.Adjustment

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
end
