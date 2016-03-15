defmodule Nectar.Repo.Migrations.AddPrecisionToOrderTotal do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      modify :total, :decimal, precision: 10, scale: 2
    end
  end
end
