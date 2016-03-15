defmodule Nectar.Repo.Migrations.CreateStates do
  use Ecto.Migration

  def change do
    create table(:states) do
      add :abbr, :string
      add :name, :string
      add :country_id, references(:countries)

      timestamps
    end
    create index(:states, [:country_id])
  end
end
