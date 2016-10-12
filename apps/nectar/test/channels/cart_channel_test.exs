defmodule Nectar.CartChannelTest do
  use Nectar.ChannelCase

  alias Nectar.Order
  alias Nectar.CheckoutManager
  alias Nectar.Country
  alias Nectar.State
  alias Nectar.Product
  alias Nectar.CartManager

  setup do
    {:ok, socket} = connect(Nectar.UserSocket, %{})
    {:ok, socket: socket}
  end

  @tag pending: true
  test "move to confirmation state valid parameters if buying the last product generates a notification", %{socket: socket}do
    {cart_to_checkout, other_cart} = setup_carts
    cart_to_checkout = cart_to_checkout |> Repo.preload([line_items: :variant])
    channel_topic = "cart:#{other_cart.id}"
    variant = List.first(cart_to_checkout.line_items) |> Map.get(:variant)

    {:ok, reply, socket} = subscribe_and_join(socket, channel_topic, %{})
    assert Nectar.Variant.available_quantity(variant) != 0

    {_, c_addr}          = Nectar.TestSetup.Order.move_cart_to_address_state(cart_to_checkout)
    {_status, c_shipp}   = Nectar.TestSetup.Order.move_cart_to_shipping_state(c_addr)
    {_status, c_tax}     = Nectar.TestSetup.Order.move_cart_to_tax_state(c_shipp)
    {status, c_payment} = Nectar.TestSetup.Order.move_cart_to_payment_state(c_tax)

    assert_receive %Phoenix.Socket.Broadcast{topic: ^channel_topic, event: "new_notification", payload: %{msg: "some products in your cart are out of stock"}}
    assert status == :ok
    assert c_payment.state == "confirmation"
    assert Nectar.Variant.available_quantity(Nectar.Repo.get(Nectar.Variant, variant.id)) == 0
  end

  test "if product out of stock joining channel gives an out of stock notification", %{socket: socket}do
    {cart_to_checkout, other_cart} = setup_carts
    cart_to_checkout = cart_to_checkout |> Repo.preload([line_items: :variant])
    channel_topic = "cart:#{other_cart.id}"
    variant = List.first(cart_to_checkout.line_items) |> Map.get(:variant)
    assert Nectar.Variant.available_quantity(variant) != 0


    {_, c_addr}          = Nectar.TestSetup.Order.move_cart_to_address_state(cart_to_checkout)
    {_status, c_shipp}   = Nectar.TestSetup.Order.move_cart_to_shipping_state(c_addr)
    {_status, c_tax}     = Nectar.TestSetup.Order.move_cart_to_tax_state(c_shipp)
    {status, c_payment} = Nectar.TestSetup.Order.move_cart_to_payment_state(c_tax)

    c_confirm = Nectar.Query.Order.get!(Nectar.Repo, c_payment.id)

    {:ok, reply, socket} = subscribe_and_join(socket, channel_topic, %{})
    assert_receive %Phoenix.Socket.Broadcast{topic: ^channel_topic, event: "new_notification", payload: %{msg: "some products in your cart are out of stock"}}
    assert status == :ok
    assert c_confirm.state == "confirmation"
    assert Nectar.Variant.available_quantity(Nectar.Repo.get(Nectar.Variant, variant.id)) == 0
  end



  defp setup_cart_without_product do
    Order.cart_changeset(%Order{}, %{})
    |> Repo.insert!
  end

  defp setup_carts do
    Nectar.TestSetup.ShippingMethod.create_shipping_methods
    Nectar.TestSetup.Tax.create_taxes
    Nectar.TestSetup.PaymentMethod.create_payment_methods
    cart       = Nectar.TestSetup.Order.create_cart
    other_cart = Nectar.TestSetup.Order.create_cart
    product    = Nectar.TestSetup.Product.create_product
    master     = product.master
    quantity   = Nectar.Variant.available_quantity(master)
    {_status, _line_item} = CartManager.add_to_cart(cart.id, %{"variant_id" => master.id, "quantity" => quantity})
    {_status, _line_item} = CartManager.add_to_cart(other_cart.id, %{"variant_id" => master.id, "quantity" => quantity})
    {cart, other_cart}
  end

end
