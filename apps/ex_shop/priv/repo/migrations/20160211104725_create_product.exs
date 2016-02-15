defmodule ExShop.Repo.Migrations.CreateProduct do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string
      add :description, :text
      add :available_on, :datetime
      add :discontinue_on, :datetime
      add :slug, :string

      timestamps
    end

    create unique_index(:products, [:slug])
  end
end
