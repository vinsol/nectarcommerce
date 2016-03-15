defmodule Nectar.Repo.Migrations.AddFullfilledToLineItem do
  use Ecto.Migration

  def change do
    alter table(:line_items) do
      add :fullfilled, :boolean, default: true
    end
  end
end
