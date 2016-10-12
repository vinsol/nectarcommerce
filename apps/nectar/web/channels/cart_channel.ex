defmodule Nectar.CartChannel do
  use Nectar.Web, :channel

  def join("cart:" <> cart_id, _params, socket) do
    cart_id = cart_id
    CartEventManager.send_notification_if_out_of_stock_on_joining(String.to_integer(cart_id))
    {:ok, %{}, assign(socket, :cart_id, cart_id)}
  end

  def handle_in("new_notification", params, socket) do
    IO.inspect "Recieved new notification"
    broadcast! socket, "new_notification", %{
      msg: params["msg"]
    }
    {:reply, :ok, socket}
  end

  def send_out_of_stock_notification(id) do
    Nectar.Endpoint.broadcast "cart:#{id}", "new_notification", %{msg: "some products in your cart are out of stock"}
  end
end
