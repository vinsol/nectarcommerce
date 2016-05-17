defmodule Nectar.Repo.Migrations.CreateShippmentUnit do
  use Ecto.Migration

  def change do
    create table(:shipment_units) do
      add :shipping_method_id, references(:shipping_methods)
      timestamps
    end

  end
end
