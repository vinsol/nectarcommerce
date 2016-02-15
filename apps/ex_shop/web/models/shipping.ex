defmodule ExShop.Shipping do
	use ExShop.Web, :model

  schema "order_shippings" do
    belongs_to :order, ExShop.Order
    belongs_to :shipping_method, ExShop.ShippingMethod
    has_one :adjustment, ExShop.Adjustment
    field :selected, :boolean, default: false
    timestamps
  end

  @required_fields ~w()
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
  end
end
