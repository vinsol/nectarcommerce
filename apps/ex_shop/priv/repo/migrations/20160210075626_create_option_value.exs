defmodule ExShop.Repo.Migrations.CreateOptionValue do
  use Ecto.Migration

  def change do
    create table(:option_values) do
      add :name, :string
      add :presentation, :string
      add :position, :integer
      add :option_type_id, references(:option_types, on_delete: :nothing)

      timestamps
    end
    create index(:option_values, [:option_type_id])
    create unique_index(:option_values, [:name, :option_type_id], name: :option_values_name_option_type_index)

  end
end
