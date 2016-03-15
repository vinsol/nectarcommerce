defmodule Nectar.Repo.Migrations.CreateZone do
  use Ecto.Migration

  def change do
    create table(:zones) do
      add :name, :string
      add :description, :string
      add :type, :string
      timestamps
    end

    create unique_index(:zones, [:name])

  end
end
