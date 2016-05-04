defmodule Nectar.ZoneMember do
  use Nectar.Web, :model

  schema "abstract table:zone_members" do
    field :zoneable_id, :integer
    belongs_to :zone, Nectar.Zone
    timestamps
    extensions
  end

  @required_fields ~w(zoneable_id zone_id)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  # do not need the params for now.
  def changeset(zoneable, %Nectar.Zone{id: zone_id}, _params) do
    zoneable
    |> Ecto.build_assoc(:zone_members)
    |> changeset(%{zone_id: zone_id})
  end

end
