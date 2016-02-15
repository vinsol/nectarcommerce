defmodule ExShop.Repo.Migrations.CreateOrder do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :slug, :string
      add :state, :string, default: "cart"
      timestamps
    end
  end
end
