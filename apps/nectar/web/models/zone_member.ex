defmodule Nectar.ZoneMember do
  use Nectar.Web, :model

  schema "abstract table:zone_members" do
    field :zoneable_id, :integer
    belongs_to :zone, Nectar.Zone

    timestamps()
    extensions()
  end

  @required_fields ~w(zoneable_id zone_id)a
  @optional_fields ~w()a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

end
