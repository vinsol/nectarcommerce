defmodule Nectar.Repo.Migrations.CreateProductCategory do
  use Ecto.Migration

  def change do
    create table(:product_categories) do
      add :category_id, references(:categories)
      add :product_id, references(:products)
      timestamps
    end
    create unique_index(:product_categories, [:category_id, :product_id], name: :unique_product_category)
  end
end
