defmodule Nectar.Admin.LineItemReturnController do
  use Nectar.Web, :admin_controller

  plug Guardian.Plug.EnsureAuthenticated, handler: Nectar.Auth.HandleAdminUnauthenticated, key: :admin

  alias Nectar.Repo
  alias Nectar.LineItemReturn

  def index(conn, _params) do
    line_item_returns = Repo.all(LineItemReturn)
    render(conn, "index.html", line_item_returns: line_item_returns, conn: conn)
  end

  def update(conn, %{"status" => status} = params) do
    line_item_return = Repo.get(LineItemReturn, params["id"])
    IO.inspect line_item_return
    case LineItemReturn.stock_and_order_update(line_item_return) do
      {:ok, line_item_return} ->
        text conn, "Done"
      {:error, changeset} ->
        IO.inspect changeset.errors
        text conn, Enum.reduce(changeset.errors, "", fn(x, acc) -> "Error" end)
    end
  end
end
