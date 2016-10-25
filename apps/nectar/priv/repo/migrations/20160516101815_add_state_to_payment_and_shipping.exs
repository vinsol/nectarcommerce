defmodule Nectar.Repo.Migrations.AddStateToPaymentAndShipping do
  use Ecto.Migration

  def change do
    alter table(:payments) do
      add :payment_state, :string
    end

    alter table(:shippings) do
      add :shipping_state, :string
    end
  end
end
