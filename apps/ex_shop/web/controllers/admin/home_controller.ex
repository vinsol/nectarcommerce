defmodule ExShop.Admin.HomeController do
  use ExShop.Web, :admin_controller

  plug Guardian.Plug.EnsureAuthenticated, handler: ExShop.Auth.HandleUnauthenticated, key: :admin

  def index(conn, _params) do
    render(conn, "index.html")
  end

end
