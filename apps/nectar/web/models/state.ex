defmodule Nectar.State do
  use Nectar.Web, :model

  schema "states" do
    field :abbr, :string
    field :name, :string

    belongs_to :country, Nectar.Country

    has_many :zone_members, {"state_zone_members", Nectar.ZoneMember}, foreign_key: :zoneable_id
    has_many :zones, through: [:zone_members, :zone]

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
