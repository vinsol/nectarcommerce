defmodule Nectar.Admin.HomeController do
  use NectarCore.Web, :admin_controller

  plug Guardian.Plug.EnsureAuthenticated, handler: Nectar.Auth.HandleAdminUnauthenticated, key: :admin

  def index(conn, _params) do
    render(conn, "index.html")
  end

end
