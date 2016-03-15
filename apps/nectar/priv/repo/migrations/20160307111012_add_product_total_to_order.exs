defmodule Nectar.Repo.Migrations.AddProductTotalToOrder do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :product_total, :decimal, default: 0
    end
  end
end
