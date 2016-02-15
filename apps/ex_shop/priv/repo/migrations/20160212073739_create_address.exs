defmodule ExShop.Repo.Migrations.CreateAddress do
  use Ecto.Migration

  def change do
    create table(:addresses) do
      add :address_line_1, :string
      add :address_line_2, :string
      add :state_id, :integer
      add :country_id, :integer

      timestamps
    end
    create index(:addresses, [:country_id, :state_id])
  end
end
