defmodule Nectar.Admin.UserOrderController do
  use NectarCore.Web, :admin_controller

  alias Nectar.User
  alias Nectar.Order

  plug Guardian.Plug.EnsureAuthenticated, handler: Nectar.Auth.HandleAdminUnauthenticated, key: :admin

  def all_pending_orders(conn, %{"user_id" => id}) do
    user = Repo.get!(User, id)
    orders = Order.all_abandoned_orders_for(user) |> Repo.all
    render(conn, "pending_orders.json", orders: orders, conn: conn)
  end

end
