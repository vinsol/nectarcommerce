defmodule Nectar.Repo.Migrations.CreateLineItemReturn do
  use Ecto.Migration

  def change do
    create table(:line_item_returns) do
      add :quantity, :integer
      add :status, :integer
      add :line_item_id, references(:line_items, on_delete: :nothing)

      timestamps
    end
    create index(:line_item_returns, [:line_item_id])

  end
end
