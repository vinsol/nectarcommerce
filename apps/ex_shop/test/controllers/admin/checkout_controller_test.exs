defmodule ExShop.Admin.CheckoutControllerTest do
	use ExShop.ConnCase

  alias ExShop.Order
  alias ExShop.Country
  alias ExShop.State
  alias ExShop.Product
  alias ExShop.CartManager

  test "checkout flow" do
    cart = setup_cart

    address_page_conn = get(conn, admin_order_checkout_path(conn, :checkout, cart))
    assert html_response(address_page_conn, 200) =~ "Address"


    shipping_page_conn = put(conn, admin_order_checkout_path(conn, :next, cart), order: valid_address_params)
    assert html_response(shipping_page_conn, 200) =~ "Select your shipping method"

    tax_page_conn = put(conn, admin_order_checkout_path(conn, :next, cart), order: valid_shipping_params(cart))
    assert html_response(tax_page_conn, 200) =~ "Confirm"

    payment_page_conn = put(conn, admin_order_checkout_path(conn, :next, cart), order: %{"tax_confirm" => true})
    assert html_response(payment_page_conn, 200) =~ "Select your payment method"

    confirmation_page_conn = put(conn, admin_order_checkout_path(conn, :next, cart), order: valid_payment_params(cart))
    assert html_response(confirmation_page_conn, 200) =~ "Confirm"

    order_success_page_conn = put(conn, admin_order_checkout_path(conn, :next, cart), order: %{"confirm" => true})
    assert html_response(order_success_page_conn, 200) =~ "Order placed successfully"
  end

  defp setup_cart_without_product do
    create_shipping_methods
    create_taxations
    create_payment_methods
    Order.cart_changeset(%Order{}, %{})
    |> Repo.insert!
  end

  @product_data %{name: "Sample Product",
    description: "Sample Product for testing without variant",
    available_on: Ecto.Date.utc,
  }
  @max_master_quantity 3
  @master_cost_price Decimal.new("30.00")
  @product_master_variant_data %{
    master: %{
      cost_price: @master_cost_price,
      quantity: @max_master_quantity
    }
  }
  @product_attr Map.merge(@product_data, @product_master_variant_data)

  defp setup_cart do
    cart = setup_cart_without_product
    product = create_product
    quantity = 2
    {_status, _line_item} = CartManager.add_to_cart(cart.id, %{"variant_id" => product.id, "quantity" => quantity})
    cart
  end


  defp create_product do
    product = Product.create_changeset(%Product{}, @product_attr)
    |> Repo.insert!
    product.master
  end

  @address_parameters  %{"address_line_1" => "address line 12", "address_line_2" => "address line 22"}

  defp valid_address_params do
    address = Dict.merge(@address_parameters, valid_country_and_state_ids)
    %{"shipping_address" => address, "billing_address" => address}
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
    Enum.each(shipping_methods, fn(method_name) ->
      ExShop.ShippingMethod.changeset(%ExShop.ShippingMethod{}, %{name: method_name})
      |> ExShop.Repo.insert!
    end)
  end

  defp create_taxations do
    taxes = ["VAT", "GST"]
    Enum.each(taxes, fn(tax_name) ->
      ExShop.Tax.changeset(%ExShop.Tax{}, %{name: tax_name})
      |> ExShop.Repo.insert!
    end)
  end

  defp create_payment_methods do
    payment_methods = ["Cheque", "Call With a card"]
    Enum.each(payment_methods, fn(method_name) ->
      ExShop.PaymentMethod.changeset(%ExShop.PaymentMethod{}, %{name: method_name})
      |> ExShop.Repo.insert!
    end)
  end

  defp valid_shipping_params(%Order{"id": id}) do
    cart =
      Repo.get(Order, id)
      |> Repo.preload([:shippings])
    [%{__struct__: _,id: shipping_id} , %{__struct__: _, id: shipping_id_2}] = cart.shippings
    %{"shippings" => [%{"id" => shipping_id, "selected" => true}, %{"id" => shipping_id_2, "selected" => false}]}
  end

  defp valid_payment_params(%Order{"id": id}) do
    cart =
      Repo.get(Order, id)
      |> Repo.preload([:payments])

    [%{__struct__: _,id: payment_id} , %{__struct__: _, id: payment_id_2}] = cart.payments
    %{"payments" => [%{"id" => payment_id, "selected" => true}, %{"id" => payment_id_2, "selected" => false}]}
  end

end
