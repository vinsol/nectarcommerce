defmodule Nectar.Admin.RefundController do
  use Nectar.Web, :admin_controller

  plug Guardian.Plug.EnsureAuthenticated, handler: Nectar.Auth.HandleAdminUnauthenticated, key: :admin

  alias Nectar.Repo
  alias Nectar.LineItemReturn
  alias Nectar.Refund

  def index(conn, _params) do
    text conn, "Works"
  end

  def create(conn, %{"amount" => amount, "line_item_return_id" => line_item_return_id} = params) do
    # Create refund for return for no more value than return
    line_item_return = Repo.get(LineItemReturn, params["line_item_return_id"]) |> Repo.preload([:refund])
    changeset = Ecto.build_assoc(line_item_return, :refund) |> Refund.create_changeset(params)
    case Repo.insert(changeset) do
      {:ok, refund} ->
        conn
          |> put_flash(:info, "Refund created successfully")
          |> redirect(to: admin_line_item_return_path(conn, :index))
      {:error, changeset} ->
        conn
          |> put_flash(:error, "Refund creation failed")
          |> redirect(to: admin_line_item_return_path(conn, :index))
    end
  end
end
