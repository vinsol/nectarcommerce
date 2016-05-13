defmodule Nectar.Admin.ChannelEchoController do
  use Nectar.Web, :admin_controller

  plug Guardian.Plug.EnsureAuthenticated, handler: Nectar.Auth.HandleAdminUnauthenticated, key: :admin

  def echo(conn, _params) do
    render(conn, "echo.html")
  end

  def do_echo(conn, %{"echo" => echo_params}) do
    topic = echo_params["topic"]
    event = echo_params["event"]
    payload = Poison.Parser.parse! echo_params["payload"]
    Nectar.Endpoint.broadcast topic, event, payload
    render(conn, "echo.html")
  end
end
