defmodule ExShop.Repo.Migrations.CreateCountries do
  use Ecto.Migration

  def change do
    create table(:countries) do
      add :name, :string
      add :iso,  :string
      add :iso3, :string
      add :iso_name, :string
      add :numcode, :string
      add :has_states, :boolean, default: false

      timestamps
    end
    create index(:countries, [:iso])
  end
end
