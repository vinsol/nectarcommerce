defmodule FavoriteProductsPhoenix.Admin.FavoriteController do
  use Nectar.Web, :admin_controller

  plug Guardian.Plug.EnsureAuthenticated, handler: Nectar.Auth.HandleAdminUnauthenticated, key: :admin

  def index(conn, _params) do
    products = Repo.all(Nectar.Product) |> Repo.preload([:liked_by])
    render conn, "index.html", products: products
  end

end
