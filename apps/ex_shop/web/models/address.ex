defmodule ExShop.Address do
	use ExShop.Web, :model

  schema "addresses" do
    field :address_line_1, :string
    field :address_line_2, :string

    belongs_to :state, ExShop.State
    belongs_to :country, ExShop.Country

    timestamps
  end
end
