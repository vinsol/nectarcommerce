defmodule Nectar.Repo.Migrations.AddShippmentUnitIdToLineItems do
  use Ecto.Migration

  def change do
    alter table(:line_items) do
      add :shipment_unit_id, references(:shipment_units)
    end
  end
end
