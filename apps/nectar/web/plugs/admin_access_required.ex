defmodule Nectar.Plugs.AdminAccessRequired do

  def init(_opts) do
  end

  def call(conn, _) do
    current_user = Guardian.Plug.current_resource(conn)
    cond do
      is_nil(current_user) ->
        conn
        |> Phoenix.Controller.put_flash(:error, "Please log in before continuing")
        |> Phoenix.Controller.redirect(to: Nectar.Router.Helpers.session_path(conn, :new))
        |> Plug.Conn.halt()
      !Nectar.User.admin?(current_user) ->
        conn
        |> Phoenix.Controller.put_flash(:error, "Access Denied!")
        |> Phoenix.Controller.redirect(to: Nectar.Router.Helpers.home_path(conn, :index))
        |> Plug.Conn.halt()
      true ->
        conn
    end
  end

end
