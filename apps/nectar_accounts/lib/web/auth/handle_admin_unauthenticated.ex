defmodule Nectar.Auth.HandleAdminUnauthenticated do

  alias Nectar.Router.Helpers, as: NectarRoutes

  use Phoenix.Controller

  def unauthenticated(conn, _params) do
    conn
    |> put_flash(:error, "Admin authentication required")
    |> redirect(to: NectarRoutes.admin_session_path(conn, :new))
  end
end
