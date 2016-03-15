defmodule Nectar.Repo.Migrations.AddAddressTypeToAddresses do
  use Ecto.Migration

  def change do
    alter table(:addresses) do
      add :address_type, :integer, default: 1
    end
  end
end
