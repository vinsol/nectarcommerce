defmodule ExShop.Auth.HandleUnauthenticated do

  import ExShop.Router.Helpers, only: [session_path: 2]

  use Phoenix.Controller

  def unauthenticated(conn, _params) do
    conn
    |> put_flash(:error, "Please login to continue")
    |> redirect(to: session_path(conn, :new))
  end
end
