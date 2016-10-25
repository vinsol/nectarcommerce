defmodule Nectar.Repo.Migrations.AddTransactionIdToPayments do
  use Ecto.Migration

  def change do
    alter table(:payments) do
      add :transaction_id, :string
    end
  end
end
