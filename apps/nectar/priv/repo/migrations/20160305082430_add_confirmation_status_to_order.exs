defmodule Nectar.Repo.Migrations.AddConfirmationStatusToOrder do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :confirmation_status, :boolean, default: true
    end
  end
end
