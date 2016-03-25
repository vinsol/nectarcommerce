defmodule FavoriteProductsPhoenix.PageController do
  use FavoriteProductsPhoenix.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
