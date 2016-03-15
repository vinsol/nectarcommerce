defmodule Nectar.Repo.Migrations.CreateDummyProduct do
  use Ecto.Migration

  def change do
    create table(:not_products) do
      add :name, :string
      add :quantity, :integer
      add :cost, :decimal
    end
  end
end
