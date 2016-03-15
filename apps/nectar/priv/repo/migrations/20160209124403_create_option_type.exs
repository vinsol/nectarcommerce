defmodule Nectar.Repo.Migrations.CreateOptionType do
  use Ecto.Migration

  def change do
    create table(:option_types) do
      add :name, :string
      add :presentation, :string
      add :position, :integer

      timestamps
    end
    create unique_index(:option_types, [:name])

  end
end
