defmodule ExShop.Repo.Migrations.CreatePaymentMethod do
  use Ecto.Migration

  def change do
    create table(:payment_methods) do
      add :name, :string
    end
  end
end
