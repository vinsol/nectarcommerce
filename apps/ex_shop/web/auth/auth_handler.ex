defmodule ExShop.AuthHandler do
  defmacro __using__(which) when is_atom(which) do
    quote do
      plug Guardian.Plug.EnsureAuthenticated, handler: __MODULE__, key: unquote(which)

      def unauthenticated(conn, _params) do
        conn
        |> put_flash(:error, "#{Phoenix.Naming.humanize(unquote(which))} authentication required")
        |> redirect(to: admin_session_path(conn, :new))
      end
    end
  end
end
