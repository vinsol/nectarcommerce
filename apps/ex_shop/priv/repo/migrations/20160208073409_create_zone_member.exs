defmodule ExShop.Repo.Migrations.CreateZoneMember do
  use Ecto.Migration

  def change do
    create table(:country_zone_members) do
      add :zoneable_id, :integer
      add :zone_id, :integer
      timestamps
    end
    create unique_index(:country_zone_members, [:zoneable_id, :zone_id])

    create table(:state_zone_members) do
      add :zoneable_id, :integer
      add :zone_id, :integer
      timestamps
    end
    create unique_index(:state_zone_members, [:zoneable_id, :zone_id])

  end
end
