defmodule ExShop.Repo.Migrations.CreateAdjustment do
  use Ecto.Migration

  def change do
    create table(:adjustments) do
      add :shipping_id, :integer
      add :tax_id, :integer
      add :order_id, :integer
      add :amount, :decimal

      timestamps
    end
  end
end
