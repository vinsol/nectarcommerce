defmodule Nectar.Country do
  use Nectar.Web, :model

  schema "countries" do
    field :name,       :string
    field :iso,        :string
    field :iso3,       :string
    field :iso_name,   :string
    field :numcode,    :string
    field :has_states, :boolean, default: false
    has_many :states, Nectar.State
    # Country can belong to many Zone via zone members
    has_many :zone_members, {"country_zone_members", Nectar.ZoneMember}, foreign_key: :zoneable_id

    has_many :zones, through: [:zone_members, :zone]

    timestamps
    extensions
  end

  @required_fields ~w(name iso3 iso has_states)
  @optional_fields ~w(numcode iso_name)

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:iso,  is: 2)
    |> validate_length(:iso3, is: 3)
    |> unique_constraint(:iso)
    |> unique_constraint(:iso3)
    |> unique_constraint(:name)
    |> unique_constraint(:numcode)
    |> build_iso_name
  end

  defp build_iso_name(model) do
    name = get_change(model, :name)
    if name do
      put_change(model, :iso_name, String.upcase(name))
    else
      model
    end
  end
end
