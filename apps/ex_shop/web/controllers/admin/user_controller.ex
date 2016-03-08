defmodule ExShop.Admin.UserController do
  use ExShop.Web, :admin_controller

  plug Guardian.Plug.EnsureAuthenticated, handler: ExShop.Auth.HandleUnauthenticated, key: :admin

  alias ExShop.User
  alias ExShop.Order
  alias ExShop.Repo

  def all_pending_orders(conn, %{"user_id" => id}) do
    user = Repo.get!(User, id)
    orders = Repo.all Order.all_abandoned_orders_for(user)
    render(conn, "pending_orders.json",  orders: orders)
  end


end
