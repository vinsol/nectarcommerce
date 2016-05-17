defmodule Nectar.Repo.Migrations.CreateShipment do
  use Ecto.Migration

  def change do
    create table(:shipments) do

      timestamps
    end

  end
end
