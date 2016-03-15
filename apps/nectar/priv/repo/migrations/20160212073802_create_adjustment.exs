defmodule Nectar.Repo.Migrations.CreateAdjustment do
  use Ecto.Migration

  def change do
    create table(:adjustments) do
      add :shipping_id, references(:shippings)
      add :order_id, references(:orders)
      add :amount, :decimal

      timestamps
    end
  end
end
