defmodule Nectar.Repo.Migrations.AddOrderStateToOrder do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :order_state,    :string
    end
  end
end
