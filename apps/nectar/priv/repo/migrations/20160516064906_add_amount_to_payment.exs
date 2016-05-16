defmodule Nectar.Repo.Migrations.AddAmountToPayment do
  use Ecto.Migration

  def change do
    alter table(:payments) do
      add :amount, :decimal
    end
  end
end
