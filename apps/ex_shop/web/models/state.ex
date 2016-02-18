defmodule ExShop.State do
  use ExShop.Web, :model

  schema "states" do
    field :abbr, :string
    field :name, :string

    belongs_to :country, ExShop.Country
    has_many :zones, {"state_zone_members", ExShop.ZoneMember}, foreign_key: :zoneable_id

    timestamps
  end

  @required_fields ~w(name abbr country_id)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:country_id)
  end
end
