defmodule ExShop.Repo.Migrations.CreatePayment do
  use Ecto.Migration

  def change do
    create table(:payments) do
      add :order_id, :integer
      add :payment_method_id, :integer
      add :selected, :boolean
      timestamps
    end
  end
end
