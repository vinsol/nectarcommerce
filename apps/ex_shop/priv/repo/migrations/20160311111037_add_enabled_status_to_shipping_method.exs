defmodule ExShop.Repo.Migrations.AddEnabledStatusToShippingMethod do
  use Ecto.Migration

  def change do
    alter table(:shipping_methods) do
      add :enabled, :boolean, default: false
    end
  end
end
