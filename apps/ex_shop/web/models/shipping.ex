defmodule ExShop.Shipping do
	use ExShop.Web, :model

  schema "shippings" do
    belongs_to :order, ExShop.Order
    belongs_to :shipping_method, ExShop.ShippingMethod
    has_one :adjustment, ExShop.Adjustment
    field :selected, :boolean, default: false
    timestamps
  end

  @required_fields ~w()
  @optional_fields ~w(shipping_method_id selected)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
