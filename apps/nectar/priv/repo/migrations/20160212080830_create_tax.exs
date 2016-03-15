defmodule Nectar.Repo.Migrations.CreateTax do
  use Ecto.Migration

  def change do
    create table(:taxes) do
      add :name, :string

      timestamps
    end
  end
end
