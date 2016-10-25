defmodule Nectar.Admin.HomeController do
  use Nectar.Web, :admin_controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

end
