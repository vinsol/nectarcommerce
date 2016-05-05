defmodule FavoriteProducts.FavoriteController do
  use FavoriteProducts.Web, :controller
  use Guardian.Phoenix.Controller

  alias Nectar.Repo
  alias Nectar.User
  alias Nectar.Product

  alias FavoriteProducts.UserLike
  alias Nectar.Router.Helpers, as: NectarRoutes

  plug Guardian.Plug.EnsureAuthenticated, handler: Nectar.Auth.HandleUnauthenticated

  def index(conn, _params, current_user, _claims) do
    liked_products = Repo.all(User.liked_products(current_user))
    all_products = Repo.all(Product)
    render conn, "index.html", liked_products: liked_products, all_products: all_products
  end

  def create(conn, %{"product_id" => product_id}, current_user, _claims) do
    changeset = UserLike.changeset(%UserLike{}, %{"product_id" => product_id, "user_id" => current_user.id})
    case Repo.insert(changeset) do
      {:ok, _product} ->
        conn
        |> put_flash(:info, "Product favorited successfully.")
        |> redirect(to: NectarRoutes.favorite_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:info, "Product favorited failed #{changeset.errors[:product_id]}")
        |> redirect(to: NectarRoutes.favorite_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => id}, current_user, _claims) do
    user_like = Repo.one(from u in UserLike, where: (u.product_id == ^id and u.user_id == ^current_user.id))

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user_like)

    conn
    |> put_flash(:info, "Product removed from favorites successfully.")
    |> redirect(to: NectarRoutes.favorite_path(conn, :index))
  end
end
