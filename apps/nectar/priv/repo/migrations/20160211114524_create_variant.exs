defmodule Nectar.Repo.Migrations.CreateVariant do
  use Ecto.Migration

  def change do
    create table(:variants) do
      add :is_master, :boolean, default: false
      add :sku, :string
      add :weight, :decimal
      add :height, :decimal
      add :width, :decimal
      add :depth, :decimal
      add :discontinue_on, :date
      add :cost_price, :decimal
      add :cost_currency, :string
      add :product_id, references(:products, on_delete: :nothing)
      add :image, :string

      timestamps
    end
    create index(:variants, [:product_id])

  end
end
