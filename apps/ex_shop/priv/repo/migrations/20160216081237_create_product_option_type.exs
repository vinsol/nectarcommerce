defmodule ExShop.Repo.Migrations.CreateProductOptionType do
  use Ecto.Migration

  def change do
    create table(:product_option_types) do
      add :product_id, references(:products, on_delete: :nothing)
      add :option_type_id, references(:option_types, on_delete: :nothing)

      timestamps
    end
    create index(:product_option_types, [:product_id])
    create index(:product_option_types, [:option_type_id])

    create unique_index(:product_option_types, [:product_id, :option_type_id], name: :unique_product_option_types_index)
  end
end
