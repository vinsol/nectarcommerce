defmodule ExShop.Address do
	use ExShop.Web, :model

  schema "addresses" do
    field :address_line_1, :string
    field :address_line_2, :string

    belongs_to :state, ExShop.State
    belongs_to :country, ExShop.Country
    belongs_to :order, ExShop.Order

    timestamps
  end

  @required_fields ~w(address_line_1 address_line_2)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
