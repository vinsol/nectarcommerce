defmodule ExShop.ShippingMethod do
  use ExShop.Web, :model

  schema "shipping_methods" do
    field :name

    timestamps
  end

end
