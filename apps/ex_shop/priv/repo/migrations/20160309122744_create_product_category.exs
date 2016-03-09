defmodule ExShop.Repo.Migrations.CreateProductCategory do
  use Ecto.Migration

  def change do
    create table(:product_categories) do
      add :category_id, references(:categories)
      add :product_id, references(:products)
      timestamps
    end

  end
end
