defmodule ExShop.Country do
  use ExShop.Web, :model

  schema "countries" do
    field :name,       :string
    field :iso,        :string
    field :iso3,       :string
    field :iso_name,   :string
    field :numcode,    :string
    field :has_states, :boolean
    has_many :states, ExShop.State
    # Country can belong to many Zone via zone members
    has_many :zone_members, {"country_zone_members", ExShop.ZoneMember}, foreign_key: :zoneable_id

    has_many :zones, through: [:zone_members, :zone]

    timestamps
  end

  @required_fields ~w(name iso3 iso iso_name has_states)
  @optional_fields ~w(numcode)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:iso,  is: 2)
    |> validate_length(:iso3, is: 3)
  end

  def user_create_changeset(model, params \\ :empty) do
    changeset(model, Map.merge(params, %{"has_states" => false, "iso_name" => build_iso_name params[:name] }))
  end

  defp build_iso_name(name) do
    String.upcase(name || "")
  end

end
