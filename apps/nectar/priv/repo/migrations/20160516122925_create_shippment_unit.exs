defmodule Nectar.Repo.Migrations.CreateShippmentUnit do
  use Ecto.Migration

  def change do
    create table(:shipment_units) do

      timestamps
    end

  end
end
