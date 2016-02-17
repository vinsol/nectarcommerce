defmodule ExShop.Repo.Migrations.CreateVariantOptionValue do
  use Ecto.Migration

  def change do
    create table(:variant_option_values) do
      add :variant_id, references(:variants, on_delete: :nothing)
      add :option_value_id, references(:option_values, on_delete: :nothing)

      timestamps
    end
    create index(:variant_option_values, [:variant_id])
    create index(:variant_option_values, [:option_value_id])

  end
end
