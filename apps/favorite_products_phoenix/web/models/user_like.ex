defmodule FavoriteProductsPhoenix.UserLike do
  use FavoriteProductsPhoenix.Web, :model

  schema "user_likes" do
    belongs_to :user, Nectar.User
    belongs_to :product, Nectar.Product
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(), ~w(user_id product_id))
  end

end
