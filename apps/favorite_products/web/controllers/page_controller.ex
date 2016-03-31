defmodule FavoriteProducts.PageController do
  use FavoriteProducts.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
