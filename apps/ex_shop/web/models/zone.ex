defmodule ExShop.Zone do
  use ExShop.Web, :model

  schema "zones" do
    field :name, :string
    field :description, :string
    field :type, :string

    has_many :country_zone_members, {"country_zone_members", ExShop.ZoneMember}, on_replace: :delete
    has_many :state_zone_members, {"state_zone_members", ExShop.ZoneMember}

    timestamps
  end

  @required_fields ~w(name description type)
  @optional_fields ~w()

  @zone_types ~w(Country State)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_inclusion(:type, @zone_types)
  end

  def zone_types, do: @zone_types


  # TODO: give better name
  def zoneable(%ExShop.Zone{type: "Country"} = _model, zoneable_id), do: ExShop.Repo.get!(ExShop.Country, zoneable_id)
  def zoneable(%ExShop.Zone{type: "State"}   = _model, zoneable_id), do: ExShop.Repo.get!(ExShop.State, zoneable_id)

  def member_with_id(%ExShop.Zone{type: "Country"} = model, zone_member_id) do
    ExShop.Repo.one from m in assoc(model, :country_zone_members), where: m.id == ^zone_member_id
  end

  def member_with_id(%ExShop.Zone{type: "State"} = model, zone_member_id) do
    ExShop.Repo.one from m in assoc(model, :state_zone_members), where: m.id == ^zone_member_id
  end

  def zoneable_candidates(%ExShop.Zone{type: "Country"} = model) do
    ExShop.Repo.all(from c in ExShop.Country, where: not c.id in ^existing_zoneable_ids(model))
  end
  def zoneable_candidates(%ExShop.Zone{type: "State"} = model) do
    ExShop.Repo.all(from s in ExShop.State, where: not s.id in ^existing_zoneable_ids(model))
  end

  def member_ids_and_names(%ExShop.Zone{type: "Country"} = model) do
    from v in assoc(model, :country_zone_members),
    join: c in ExShop.Country, on: c.id == v.zoneable_id,
    select: {v.id, c.name}
  end
  def member_ids_and_names(%ExShop.Zone{type: "State"} = model) do
    from v in assoc(model, :state_zone_members),
    join: c in ExShop.State, on: c.id == v.zoneable_id,
    select: {v.id, c.name}
  end

  def members(%ExShop.Zone{type: "Country"} = model) do
    from v in assoc(model, :country_zone_members)
  end
  def members(%ExShop.Zone{type: "State"} = model) do
    from v in assoc(model, :state_zone_members)
  end

  defp existing_zoneable_ids(%ExShop.Zone{type: "State"} = model)   ,do: ExShop.Repo.all from cz in assoc(model, :state_zone_members), select: cz.zoneable_id
  defp existing_zoneable_ids(%ExShop.Zone{type: "Country"} = model) ,do: ExShop.Repo.all from cz in assoc(model, :country_zone_members), select: cz.zoneable_id
end
