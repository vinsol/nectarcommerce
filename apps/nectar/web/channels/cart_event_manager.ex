defmodule CartEventManager do
  use GenEvent
  alias Nectar.Order

  # based on: http://learningelixir.joekain.com/using-genevent-to-notify-a-channel/
  @name :cart_event_manager

  def child_spec, do: Supervisor.Spec.worker(GenEvent, [[name: @name]])

  def send_notification_if_out_of_stock_on_checkout(order) do
    GenEvent.notify(@name, {:out_of_stock_on_checkout, order})
  end

  def send_notification_if_out_of_stock_on_joining(order_id) do
    GenEvent.notify(@name, {:out_of_stock_on_joining, order_id})
  end


  def register(handler, args) do
    GenEvent.add_handler(@name, handler, args)
  end

  def register_with_manager do
    CartEventManager.register(__MODULE__, nil)
  end

  def handle_event({:out_of_stock_on_checkout, order}, state) do
    Enum.each(Order.out_of_stock_carts_sharing_variants_with(order), fn (%Order{id: id}) ->
      Nectar.CartChannel.send_out_of_stock_notification(id)
    end)
    {:ok, state}
  end

  def handle_event({:out_of_stock_on_joining, order_id}, state) do
    {in_stock, _} = Order.check_if_variants_in_stock(order_id)
    if not in_stock do
      Nectar.CartChannel.send_out_of_stock_notification(order_id)
    end
    {:ok, state}
  end

end
