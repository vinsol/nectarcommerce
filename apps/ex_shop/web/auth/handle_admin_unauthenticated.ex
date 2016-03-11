defmodule ExShop.Auth.HandleAdminUnauthenticated do

  import ExShop.Router.Helpers, only: [admin_session_path: 2]

  use Phoenix.Controller

  def unauthenticated(conn, _params) do
    conn
    |> put_flash(:error, "Admin authentication required")
    |> redirect(to: admin_session_path(conn, :new))
  end
end
