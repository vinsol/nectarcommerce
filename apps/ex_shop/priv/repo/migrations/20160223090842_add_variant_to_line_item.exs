defmodule ExShop.Repo.Migrations.AddVariantToLineItem do
  use Ecto.Migration

  def change do
    alter table(:line_items) do
      add    :variant_id, references(:variants)
    end
  end
end
