defmodule ExShop.Repo.Migrations.AddOptionTypeIdToVariantOptionValues do
  use Ecto.Migration

  def change do
    alter table(:variant_option_values) do
      add :option_type_id, references(:option_types, on_delete: :nothing)
    end
  end
end
