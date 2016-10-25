defmodule Nectar.Query.Zone do
  use Nectar.Query, model: Nectar.Zone
  import Ecto, only: [assoc: 2]

  def zoneable!(repo, %Nectar.Zone{type: "Country"} = _model, zoneable_id),
    do: repo.get!(Nectar.Country, zoneable_id)

  def zoneable!(repo, %Nectar.Zone{type: "State"} = _model, zoneable_id),
    do: repo.get!(Nectar.State, zoneable_id)

  def member_with_id(repo, %Nectar.Zone{type: "Country"} = model, zone_member_id) do
    repo.one(from m in assoc(model, :country_zone_members),
      where: m.id == ^zone_member_id)
  end

  def member_with_id(repo, %Nectar.Zone{type: "State"} = model, zone_member_id) do
    repo.one(from m in assoc(model, :state_zone_members),
      where: m.id == ^zone_member_id)
  end

  def zoneable_candidates(repo, %Nectar.Zone{type: "Country"} = model) do
    existing_zoneable_ids = existing_zoneable_ids(repo, model)
    repo.all(from c in Nectar.Country, where: not c.id in ^existing_zoneable_ids)
  end

  def zoneable_candidates(repo, %Nectar.Zone{type: "State"} = model) do
    existing_zoneable_ids = existing_zoneable_ids(repo, model)
    repo.all(from s in Nectar.State, where: not s.id in ^existing_zoneable_ids)
  end

  def member_ids_and_names(%Nectar.Zone{type: "Country"} = model) do
    from v in assoc(model, :country_zone_members),
    join: c in Nectar.Country, on: c.id == v.zoneable_id,
    select: {v.id, c.name}
  end
  def member_ids_and_names(%Nectar.Zone{type: "State"} = model) do
    from v in assoc(model, :state_zone_members),
    join: c in Nectar.State, on: c.id == v.zoneable_id,
    select: {v.id, c.name}
  end
  def member_ids_and_names(repo, model), do: repo.all(member_ids_and_names(model))

  def members(%Nectar.Zone{type: "Country"} = model),
    do: from v in assoc(model, :country_zone_members)

  def members(%Nectar.Zone{type: "State"} = model),
    do: from v in assoc(model, :state_zone_members)

  def members(repo, model), do: repo.all(members(model))

  defp existing_zoneable_ids(%Nectar.Zone{type: "State"} = model),
    do: from cz in assoc(model, :state_zone_members), select: cz.zoneable_id

  defp existing_zoneable_ids(%Nectar.Zone{type: "Country"} = model),
    do: from cz in assoc(model, :country_zone_members), select: cz.zoneable_id

  defp existing_zoneable_ids(repo, model),
    do: repo.all(existing_zoneable_ids(model))
end
