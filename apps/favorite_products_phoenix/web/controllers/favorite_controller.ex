defmodule FavoriteProductsPhoenix.FavoriteController do
  use FavoriteProductsPhoenix.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
