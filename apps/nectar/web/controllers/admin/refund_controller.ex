defmodule Nectar.Admin.RefundController do
  use Nectar.Web, :admin_controller

  plug Guardian.Plug.EnsureAuthenticated, handler: Nectar.Auth.HandleAdminUnauthenticated, key: :admin

  alias Nectar.Repo
  alias Nectar.LineItemReturn
  alias Nectar.Refund

  def index(conn, _params) do
    refunds = Repo.all(Refund)
    render conn, "index.html", refunds: refunds
  end

  def create(conn, %{"refund" => refund_params}) do
    # Create refund for return for no more value than return
    line_item_return = Repo.get(LineItemReturn, refund_params["line_item_return_id"]) |> Repo.preload([:refund])
    changeset = Ecto.build_assoc(line_item_return, :refund) |> Refund.create_changeset(refund_params)
    case Repo.insert(changeset) do
      {:ok, refund} ->
        conn
          |> put_flash(:info, "Refund created successfully for Return #{line_item_return.id}")
          |> redirect(to: admin_line_item_return_path(conn, :index))
      {:error, changeset} ->
        conn
          |> put_flash(:error, "Refund creation failed")
          |> redirect(to: admin_line_item_return_path(conn, :index))
    end
  end
end
