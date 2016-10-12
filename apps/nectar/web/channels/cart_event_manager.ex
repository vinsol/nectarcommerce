defmodule CartEventManager do
  use GenEvent

  # based on: http://learningelixir.joekain.com/using-genevent-to-notify-a-channel/
  @name :cart_event_manager
  alias Nectar.Repo

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
    Enum.each(Nectar.Query.Order.out_of_stock_carts_sharing_variants_with(Repo, order), fn (%Nectar.Order{id: id}) ->
      Nectar.CartChannel.send_out_of_stock_notification(id)
    end)
    {:ok, state}
  end

  def handle_event({:out_of_stock_on_joining, order_id}, state) do
    order =
      Nectar.Query.Order.get!(Repo, order_id)
      |> Repo.preload([line_items: [variant: :product]])

    {in_stock, _, _, _} = Nectar.Order.check_line_items_for_availability(order)
    if not in_stock do
      Nectar.CartChannel.send_out_of_stock_notification(order_id)
    end
    {:ok, state}
  end

end
