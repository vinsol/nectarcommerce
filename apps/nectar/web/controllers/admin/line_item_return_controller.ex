defmodule Nectar.Admin.LineItemReturnController do
  use Nectar.Web, :admin_controller

  plug Guardian.Plug.EnsureAuthenticated, handler: Nectar.Auth.HandleAdminUnauthenticated, key: :admin

  alias Nectar.Repo
  alias Nectar.LineItemReturn

  def index(conn, _params) do
    line_item_returns = Repo.all(LineItemReturn) |> Repo.preload([:refund])
    render(conn, "index.html", line_item_returns: line_item_returns, conn: conn)
  end

  def update(conn, %{"status" => status} = params) do
    line_item_return = Repo.get(LineItemReturn, params["id"])
    IO.inspect line_item_return
    case LineItemReturn.accept_or_reject(line_item_return, params) do
      {:ok, line_item_return} ->
        text conn, "Done"
      {:error, changeset} ->
        text conn, "Action Failed"
      {:noop, line_item_return} ->
        text conn, "Make sure you are not changing already changed return or invalid status"
    end
  end
end
