defmodule NectarCore.PageController do
  use NectarCore.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
