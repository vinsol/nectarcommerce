defmodule ExShop.Repo.Migrations.CreateCategory do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string
      add :parent_id, references(:categories)

      timestamps
    end

  end
end
