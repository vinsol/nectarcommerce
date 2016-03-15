defmodule Nectar.Repo.Migrations.AddQuantityToVariant do
  use Ecto.Migration

  def change do
    alter table(:variants) do
      add :quantity, :integer
    end
  end
end
