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

  test "move to confirmation state valid parameters if buying the last product generates a notification", %{socket: socket}do
    {cart_to_checkout, other_cart} = setup_carts
    cart_to_checkout = cart_to_checkout |> Repo.preload([line_items: :variant])
    channel_topic = "cart:#{other_cart.id}"
    variant = List.first(cart_to_checkout.line_items) |> Map.get(:variant)
    {:ok, reply, socket} = subscribe_and_join(socket, channel_topic, %{})
    assert Nectar.Variant.available_quantity(variant) != 0

    {_, c_addr} = move_cart_to_address_state(cart_to_checkout)
    {_status, c_shipp} = move_cart_to_shipping_state(c_addr)
    {_status, c_tax} = move_cart_to_tax_state(c_shipp)
    {_status, c_payment} = move_cart_to_payment_state(c_tax)
    {status,  c_confirm} = move_cart_to_confirmation_state(c_payment)

    assert_receive %Phoenix.Socket.Broadcast{topic: ^channel_topic, event: "new_notification", payload: %{msg: "some products in your cart are out of stock"}}
    assert status == :ok
    assert c_confirm.state == "confirmation"
    assert Nectar.Variant.available_quantity(Nectar.Repo.get(Nectar.Variant, variant.id)) == 0
  end

  test "if product out of stock joining channel gives an out of stock notification", %{socket: socket}do
    {cart_to_checkout, other_cart} = setup_carts
    cart_to_checkout = cart_to_checkout |> Repo.preload([line_items: :variant])
    channel_topic = "cart:#{other_cart.id}"
    variant = List.first(cart_to_checkout.line_items) |> Map.get(:variant)
    assert Nectar.Variant.available_quantity(variant) != 0


    {_, c_addr} = move_cart_to_address_state(cart_to_checkout)
    {_status, c_shipp} = move_cart_to_shipping_state(c_addr)
    {_status, c_tax} = move_cart_to_tax_state(c_shipp)
    {_status, c_payment} = move_cart_to_payment_state(c_tax)
    {status,  c_confirm} = move_cart_to_confirmation_state(c_payment)

    {:ok, reply, socket} = subscribe_and_join(socket, channel_topic, %{})
    assert_receive %Phoenix.Socket.Broadcast{topic: ^channel_topic, event: "new_notification", payload: %{msg: "some products in your cart are out of stock"}}
    assert status == :ok
    assert c_confirm.state == "confirmation"
    assert Nectar.Variant.available_quantity(Nectar.Repo.get(Nectar.Variant, variant.id)) == 0
  end


  defp setup do
    create_shipping_methods
    create_taxations
    create_payment_methods
  end

  defp setup_cart_without_product do
    Order.cart_changeset(%Order{}, %{})
    |> Repo.insert!
  end

  @product_data %{name: "Sample Product 2",
    description: "Sample Product for testing without variant",
    available_on: Ecto.Date.utc,
  }
  @master_cost_price Decimal.new("30.00")
  @max_master_quantity 3
  @product_master_variant_data %{
    master: %{
      cost_price: @master_cost_price,
      add_count: @max_master_quantity
    }
  }
  @product_attr Map.merge(@product_data, @product_master_variant_data)

  defp setup_carts do
    setup
    cart = setup_cart_without_product
    other_cart = setup_cart_without_product
    product = create_product
    quantity = Nectar.Variant.available_quantity(product)
    {_status, _line_item} = CartManager.add_to_cart(cart.id, %{"variant_id" => product.id, "quantity" => quantity})
    {_status, _line_item} = CartManager.add_to_cart(other_cart.id, %{"variant_id" => product.id, "quantity" => quantity})
    {cart, other_cart}
  end

  defp create_product do
    product = Product.create_changeset(%Product{}, @product_attr)
    |> Repo.insert!
    product.master
  end

  @address_parameters  %{"address_line_1" => "address line 12", "address_line_2" => "address line 22"}

  defp valid_address_params do
    address = Dict.merge(@address_parameters, valid_country_and_state_ids)
    %{"order_shipping_address" => address, "order_billing_address" => address}
  end

  defp valid_address_params_same_as_billing do
    Map.merge(valid_address_params, %{"same_as_billing" => true})
  end

  defp valid_country_and_state_ids do
    country =
      Country.changeset(%Country{}, %{"name" => "Country", "iso" => "Co",
                                    "iso3" => "Con", "numcode" => "123"})
      |> Repo.insert!
    state =
      State.changeset(%State{}, %{"name" => "State", "abbr" => "ST", "country_id" => country.id})
      |> Repo.insert!
    %{"country_id" => country.id, "state_id" => state.id}
  end

  defp create_shipping_methods do
    shipping_methods = ["regular", "express"]
    Enum.map(shipping_methods, fn(method_name) ->
      Nectar.ShippingMethod.changeset(%Nectar.ShippingMethod{}, %{name: method_name})
      |> Nectar.Repo.insert!
    end)
  end

  defp create_taxations do
    taxes = ["VAT", "GST"]
    Enum.each(taxes, fn(tax_name) ->
      Nectar.Tax.changeset(%Nectar.Tax{}, %{name: tax_name})
      |> Nectar.Repo.insert!
    end)
  end

  defp create_payment_methods do
    payment_methods = ["cheque", "Call With a card"]
    Enum.map(payment_methods, fn(method_name) ->
      Nectar.PaymentMethod.changeset(%Nectar.PaymentMethod{}, %{name: method_name})
      |> Nectar.Repo.insert!
    end)
  end

  defp move_cart_to_address_state(cart) do
    CheckoutManager.next(cart, valid_address_params)
  end

  defp move_cart_to_shipping_state(cart) do
    CheckoutManager.next(cart, valid_shipping_params(cart))
  end

  defp move_cart_to_tax_state(cart) do
    CheckoutManager.next(cart, %{"tax_confirm" => true})
  end

  defp move_cart_to_payment_state(cart) do
    CheckoutManager.next(cart, valid_payment_params(cart))
  end

  defp move_cart_to_confirmation_state(cart) do
    CheckoutManager.next(cart, %{"confirm" => true})
  end

  defp valid_shipping_params(_cart) do
    shipping_method_id = create_shipping_methods |> List.first |> Map.get(:id)
    %{"shipping" => %{"shipping_method_id" => shipping_method_id}}
  end

  defp valid_payment_params(_cart) do
    payment_method_id = create_payment_methods |> List.first |> Map.get(:id)
    %{"payment" => %{"payment_method_id" => payment_method_id}, "payment_method" => %{}}
  end

end
