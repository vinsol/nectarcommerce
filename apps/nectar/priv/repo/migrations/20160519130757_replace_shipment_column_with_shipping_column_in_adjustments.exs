defmodule Nectar.Repo.Migrations.ReplaceShipmentColumnWithShippingColumnInAdjustments do
  use Ecto.Migration

  def change do
    alter table(:adjustments) do
      add :shipment_id, references(:shipments)
      remove :shipping_id
    end
  end
end
