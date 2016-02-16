defmodule ExShop.Repo.Migrations.CreateLineItem do
  use Ecto.Migration

  def change do
    create table(:line_items) do
      add :product_id, :integer
      add :order_id, :integer
      add :quantity, :integer
      add :total, :decimal
      timestamps
    end

    create index(:line_items, [:product_id])
  end
end
