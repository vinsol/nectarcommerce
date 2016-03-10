defmodule ExShop.Plugs.Cart do
  import Plug.Conn

  def init(_opts) do
  end

  def call(conn, _) do
    current_user  = Guardian.Plug.current_resource(conn)
    current_order = fetch_current_order_from_session(conn)
    assign_cart_to_session_and_user(conn, current_user, current_order)
  end

  # conditional clauses for setting the current order
  defp assign_order_to_session_and_user(conn, user, order)

  # guest visiting for for first time
  defp assign_cart_to_session_and_user(conn, nil, nil) do
    current_order = create_guest_order
    conn
    |> assign(:current_order, current_order)
    |> put_session(:current_order, current_order.id)
  end

  # guest continuing on site, we already have an order from session
  defp assign_cart_to_session_and_user(conn, nil, order) do
    conn
    |> assign(:current_order, order)
  end

  # guest logged in, link the cart to the user
  defp assign_cart_to_session_and_user(conn, user, %ExShop.Order{user_id: nil} = order) do
    updated_order = ExShop.Order.link_to_user_changeset(order, %{user_id: user.id}) |> ExShop.Repo.update!
    conn
    |> assign(:current_order, updated_order)
  end

  # logged in user visiting after some time or just completed an order
  defp assign_cart_to_session_and_user(conn, user, nil) do
    order = load_or_create_order_for_user(user)
    conn
    |> assign(:current_order, order)
    |> put_session(:current_order, order.id)
  end

  # logged in user continuing with session
  defp assign_cart_to_session_and_user(conn, user, order) do
    conn
    |> assign(:current_order, order)
  end

  defp load_or_create_order_for_user(current_user) do
    ExShop.Order.current_order(current_user) || (ExShop.Order.user_cart_changeset(%ExShop.Order{}, %{user_id: current_user.id}) |> ExShop.Repo.insert!)
  end

  defp create_guest_order do
    ExShop.Order.cart_changeset(%ExShop.Order{}, %{}) |> ExShop.Repo.insert!
  end

  # if the order in session has been confirmed, we need to create an empty cart for
  # checkout so return nil.
  defp fetch_current_order_from_session(conn) do
    case ExShop.Repo.get(ExShop.Order, get_session(conn, :current_order) || 0) do
      nil -> nil
      %ExShop.Order{state: "confirmation"} -> nil
      order -> order
    end
  end

end
