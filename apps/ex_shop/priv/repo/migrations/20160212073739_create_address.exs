defmodule ExShop.Repo.Migrations.CreateAddress do
  use Ecto.Migration

  def change do
    create table(:addresses) do
      add :address_line_1, :string
      add :address_line_2, :string
      add :state_id, references(:states)
      add :country_id, references(:countries)
      add :order_id, references(:orders)

      timestamps
    end
    create index(:addresses, [:country_id, :state_id])
  end
end
