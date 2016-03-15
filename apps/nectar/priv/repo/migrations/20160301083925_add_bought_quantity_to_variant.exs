defmodule Nectar.Repo.Migrations.AddBoughtQuantityToVariant do
  use Ecto.Migration

  def change do
    alter table(:variants) do
      add :bought_quantity, :integer
    end
    rename table(:variants), :quantity, to: :total_quantity
  end
end
