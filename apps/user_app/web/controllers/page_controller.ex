defmodule UserApp.PageController do
  use UserApp.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
