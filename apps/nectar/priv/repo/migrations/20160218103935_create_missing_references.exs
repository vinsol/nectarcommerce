defmodule Nectar.Repo.Migrations.CreateMissingReferences do
  use Ecto.Migration

  def change do
    alter table(:shippings) do
      add :shipping_method_id, references(:shipping_methods)
    end
    alter table(:adjustments) do
      add :tax_id, references(:taxes)
    end
    alter table(:payments) do
      add :payment_method_id, references(:payment_methods)
    end
  end
end
