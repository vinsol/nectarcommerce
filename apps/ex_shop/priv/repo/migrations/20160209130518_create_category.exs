defmodule ExShop.Repo.Migrations.CreateCategory do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string
      add :parent_id, :integer, default: 0
      add :lft, :integer, null: false
      add :rgt, :integer, null: false

      timestamps
    end

    create index(:categories, [:parent_id])
    create index(:categories, [:lft])
    create index(:categories, [:rgt])

  end
end
