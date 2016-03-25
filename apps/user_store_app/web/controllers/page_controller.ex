defmodule UserStoreApp.PageController do
  use UserStoreApp.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
