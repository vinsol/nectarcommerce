defmodule Nectar.Auth.HandleUnauthenticated do

  alias Nectar.Router.Helpers, as: NectarRoutes

  use Phoenix.Controller

  def unauthenticated(conn, _params) do
    conn
    |> put_flash(:error, "Please login to continue")
    |> redirect(to: NectarRoutes.session_path(conn, :new))
  end
end
