defmodule Nectar.Repo.Migrations.AddUnitPriceToLineItem do
  use Ecto.Migration

  def change do
    alter table(:line_items) do
      add :unit_price, :decimal
    end
  end
end
