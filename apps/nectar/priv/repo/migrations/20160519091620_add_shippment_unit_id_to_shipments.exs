defmodule Nectar.Repo.Migrations.AddShipmentUnitIdToShipments do
  use Ecto.Migration

  def change do
    alter table(:shipments) do
      add :shipment_unit_id, references(:shipment_units, on_delete: :nilify_all)
    end
  end
end
