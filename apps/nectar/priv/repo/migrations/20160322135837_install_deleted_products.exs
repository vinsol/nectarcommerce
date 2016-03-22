defmodule Nectar.Repo.Migrations.InstallDeletedProducts do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add :deleted, :boolean, default: false
      add :deleted_by_id, references(:users)
    end
  end
end
