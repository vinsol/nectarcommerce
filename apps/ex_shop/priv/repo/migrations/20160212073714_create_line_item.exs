defmodule ExShop.Repo.Migrations.CreateLineItem do
  use Ecto.Migration

  def change do
    create table(:line_items) do
      add :product_id, :integer
      add :order_id, :integer
      add :quantity, :integer

      timestamps
    end

    create index(:line_items, [:product_id])
  end
end
