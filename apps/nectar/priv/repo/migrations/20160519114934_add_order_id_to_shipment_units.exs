defmodule Nectar.Repo.Migrations.AddOrderIdToShipmentUnits do
  use Ecto.Migration

  def change do
    alter table(:shipment_units) do
      add :order_id, references(:orders)
    end
  end
end
