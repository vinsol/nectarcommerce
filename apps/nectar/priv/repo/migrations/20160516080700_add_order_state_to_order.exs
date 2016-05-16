defmodule Nectar.Repo.Migrations.AddOrderStateToOrder do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :order_state,    :string
      add :payment_state,  :string
      add :shipping_state, :string
    end
  end
end
