defmodule ExShop.Admin.HomeController do
  use ExShop.Web, :controller

  plug Guardian.Plug.EnsureAuthenticated, handler: __MODULE__, key: :admin

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_flash(:error, "Admin authentication required")
    |> redirect(to: admin_session_path(conn, :new))
  end
end
