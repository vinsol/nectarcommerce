defmodule FavoriteProducts.UserLike do
  IO.puts "defining userlikes #{__MODULE__}"
  #use Nectar.Web, :model
  use Ecto.Schema

  import Ecto
  import Ecto.Changeset
  import Ecto.Query, only: [from: 1, from: 2]

  schema "user_likes" do
    belongs_to :user, Nectar.User
    belongs_to :product, Nectar.Product
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(), ~w(user_id product_id))
  end
end
