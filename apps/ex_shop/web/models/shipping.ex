defmodule ExShop.Shipping do
	use ExShop.Web, :model

  schema "order_shippings" do
    belongs_to :order, ExShop.Order
    has_one :shipping_method, ExShop.ShippingMethod

    timestamps
  end
end
