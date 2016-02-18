defmodule ExShop.Repo.Migrations.CreateLineItem do
  use Ecto.Migration

  def change do
    create table(:line_items) do
      add :product_id, references(:not_products)
      add :order_id, references(:orders)
      add :quantity, :integer
      add :total, :decimal
      timestamps
    end
  end
end
