defmodule Nectar.Repo.Migrations.CreateShippingMethod do
  use Ecto.Migration

  def change do
    create table(:shipping_methods) do
      add :name, :string
      timestamps
    end
  end
end
