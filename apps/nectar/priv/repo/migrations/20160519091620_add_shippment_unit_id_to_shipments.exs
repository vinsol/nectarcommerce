defmodule Nectar.Repo.Migrations.AddShipmentUnitIdToShipments do
  use Ecto.Migration

  def change do
    alter table(:shipments) do
      add :shipment_unit_id, references(:shipment_units)
    end
  end
end
