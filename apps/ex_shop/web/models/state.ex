defmodule ExShop.State do
  use ExShop.Web, :model

  schema "states" do
    field :abbr, :string
    field :name, :string

    belongs_to :country, ExShop.Country

    timestamps
  end

  @required_fields ~w(name abbr country_id)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
