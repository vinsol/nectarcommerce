defmodule FavoriteProductsPhoenix.FavoriteController do
  use Nectar.Web, :controller
  import FavoriteProductsPhoenix.Router.Helpers

  def index(conn, _params) do
    products = Repo.all(Nectar.Product) |> Repo.preload([:liked_by])
    render conn, "index.html", products: products
  end

  def update(conn, %{"id" => product_id}) do
    product   = Repo.get(Nectar.Product, product_id) |> Repo.preload([:likes])
    like_update_params = %{"likes" => [%{"user_id" => 1}]}
    changeset = Nectar.Product.like_changeset(product, like_update_params)

    case Repo.update(changeset) do
      {:ok, _} ->
        redirect(conn, to: favorite_path(conn, :index))
      {:error, _} ->
        conn
        |> put_flash(:error, "unable to like the product")
        |> redirect(to: favorite_path(conn, :index))
    end
  end
end
