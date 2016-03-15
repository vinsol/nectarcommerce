defmodule Nectar.Repo.Migrations.CreateAddressJoinTables do
  use Ecto.Migration

  def change do
    create table(:user_addresses) do
      add :address_id, references(:addresses)
      add :user_id, references(:users)
      timestamps
    end

    create table(:order_billing_addresses) do
      add :address_id, references(:addresses)
      add :order_id, references(:orders)
      timestamps
    end

    create table(:order_shipping_addresses) do
      add :address_id, references(:addresses)
      add :order_id, references(:orders)
      timestamps
    end

    alter table(:addresses) do
      remove :address_type
      remove :order_id
    end

  end
end
