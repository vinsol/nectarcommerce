defmodule ExShop.PageController do
  use ExShop.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
