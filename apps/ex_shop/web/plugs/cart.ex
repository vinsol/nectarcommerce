defmodule ExShop.Plugs.Cart do
  import Plug.Conn

  def init(_opts) do
  end

  def call(conn, _) do
    current_user  = conn.assigns[:current_user]
    current_order = fetch_current_order_from_session(conn)
    updated_conn  = if current_user do
      assign(conn, :current_order, current_order || load_or_create_order_for_user(current_user))
    else
      assign(conn, :current_order, current_order || create_guest_order)
    end
    put_session(updated_conn, :current_order, updated_conn.assigns.current_order.id)
  end

  defp load_or_create_order_for_user(current_user) do
    ExShop.Order.current_order(current_user) || (ExShop.Order.user_cart_changeset(%ExShop.Order{}, %{user_id: current_user.id}) |> Repo.insert!)
  end

  defp create_guest_order do
    ExShop.Order.cart_changeset(%ExShop.Order{}, %{}) |> ExShop.Repo.insert!
  end

  defp fetch_current_order_from_session(conn) do
    case ExShop.Repo.get(ExShop.Order, get_session(conn, :current_order) || 0) do
      nil -> nil
      %ExShop.Order{state: "confirmation"} -> nil
      order -> order
    end
  end

end
