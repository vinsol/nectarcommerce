defmodule ExShop.Repo.Migrations.AddEnabledStatusToPaymentMethod do
  use Ecto.Migration

  def change do
    alter table(:payment_methods) do
      add :enabled, :boolean, default: false
    end
  end
end
