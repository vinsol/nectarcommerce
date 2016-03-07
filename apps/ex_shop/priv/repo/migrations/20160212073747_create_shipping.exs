defmodule ExShop.Repo.Migrations.CreateShipping do
  use Ecto.Migration

  def change do
    create table(:shippings) do
      add :order_id, references(:orders)

      timestamps
    end
  end
end
