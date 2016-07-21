defmodule Nectar.Plugs.Cart do
  import Plug.Conn

  def init(_opts) do
  end

  def call(conn, _) do
    current_user  = Guardian.Plug.current_resource(conn)
    current_order = fetch_current_order_from_session(conn)
    assign_cart_to_session_and_user(conn, current_user, current_order)
  end

  # conditional clauses for setting the current order

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
  defp assign_cart_to_session_and_user(conn, user, %Nectar.Order{user_id: nil} = order) do
    # load previous order only if cart in current session is empty
    previous_order = if Nectar.Query.Order.cart_empty?(Nectar.Repo, order) do
      Nectar.Query.User.current_order(user)
    else
      nil
    end
    # Use the previous order only assign the blank cart if it is nil.
    updated_order = previous_order || Nectar.Command.Order.link_to_user!(Nectar.Repo, order, user.id)
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
  defp assign_cart_to_session_and_user(conn, _user, order) do
    conn
    |> assign(:current_order, order)
  end

  defp load_or_create_order_for_user(current_user) do
    Nectar.Query.User.current_order(Nectar.Repo, current_user) || (Nectar.Command.Order.create_empty_cart_for_user!(Nectar.Repo, current_user.id))
  end

  defp create_guest_order do
    Nectar.Command.Order.create_empty_cart_for_guest!(Nectar.Repo)
  end

  # if the order in session has been confirmed, we need to create an empty cart for
  # checkout so return nil.
  defp fetch_current_order_from_session(conn) do
    case Nectar.Query.Order.get(Nectar.Repo, get_session(conn, :current_order) || 0) do
      nil -> nil
      %Nectar.Order{state: "confirmation"} -> nil
      order -> order
    end
  end

end
