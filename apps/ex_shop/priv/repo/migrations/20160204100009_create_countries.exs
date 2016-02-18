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
    # This also defines the order in which unique constraint errors are raised.
    create unique_index(:countries, [:iso])
    create unique_index(:countries, [:iso3])
    create unique_index(:countries, [:name])
    create unique_index(:countries, [:numcode])
  end
end
