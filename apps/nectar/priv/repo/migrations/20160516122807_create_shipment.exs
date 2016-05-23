defmodule Nectar.Repo.Migrations.CreateShipment do
  use Ecto.Migration

  def change do
    create table(:shipments) do
      add :shipping_method_id, references(:shipping_methods)
      timestamps
    end

  end
end
