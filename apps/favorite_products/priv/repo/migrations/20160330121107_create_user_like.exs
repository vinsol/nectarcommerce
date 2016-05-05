defmodule FavoriteProducts.Repo.Migrations.CreateUserLike do
  use Ecto.Migration

  def change do
    create table(:user_likes) do
      add :user_id, references(:users, on_delete: :nothing)
      add :product_id, references(:products, on_delete: :nothing)

      timestamps
    end
    create index(:user_likes, [:user_id])
    create index(:user_likes, [:product_id])

    create unique_index(:user_likes, [:user_id, :product_id], name: :user_likes_product_unique_index)
  end
end
