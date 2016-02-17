defmodule ExShop.Repo.Migrations.CreateShipping do
  use Ecto.Migration

  def change do
    create table(:shippings) do
      add :order_id, :integer
      add :selected, :boolean
      add :shipping_method_id, :integer
      timestamps
    end
  end
end
