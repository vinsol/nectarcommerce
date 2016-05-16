defmodule Nectar.Repo.Migrations.AddRefundsTable do
  use Ecto.Migration

  def change do
    create table(:refunds) do
      add :amount, :integer
      add :line_item_return_id, :integer

      timestamps
    end

    create unique_index(:refunds, [:line_item_return_id])
  end
end
