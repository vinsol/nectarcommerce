defmodule ExShop.Repo.Migrations.CreateSetting do
  use Ecto.Migration

  def change do
    create table(:settings) do
      add :name, :string
      add :slug, :string
      add :settings, {:array, :map}, default: []
    end
    create unique_index(:settings, [:name])
  end
end
