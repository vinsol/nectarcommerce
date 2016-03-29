defmodule FavoriteProductsPhoenix.Repo.Migrations.AddUserLike do
  use Ecto.Migration

  def change do
    create table(:user_likes) do
      add :user_id, references(:users)
      add :product_id, references(:products)
    end
  end
end
