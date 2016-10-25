defmodule Nectar.Command.ZoneMember do
  use Nectar.Command, model: Nectar.ZoneMember

  def insert_for_zone(repo, zoneable, %Nectar.Zone{id: zone_id}) do
    zoneable
    |> Ecto.build_assoc(:zone_members)
    |> Nectar.ZoneMember.changeset(%{zone_id: zone_id})
    |> repo.insert
  end

end
