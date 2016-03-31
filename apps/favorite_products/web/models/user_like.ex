defmodule FavoriteProducts.UserLike do
  use FavoriteProducts.Web, :model

  schema "user_likes" do
    belongs_to :user, Nectar.User
    belongs_to :product, Nectar.Product

    timestamps
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(user_id product_id), ~w())
    |> unique_constraint(:product_id, name: :user_likes_product_unique_index)
  end
end
