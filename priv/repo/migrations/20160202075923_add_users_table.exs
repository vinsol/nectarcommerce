defmodule ExShop.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :encrypted_password, :string
      add :is_admin, :boolean, default: false

      timestamps
    end
    create unique_index(:users, [:email])
  end
end
