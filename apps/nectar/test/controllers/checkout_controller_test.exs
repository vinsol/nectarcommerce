defmodule Nectar.CheckoutControllerTest do
  use Nectar.ConnCase

  alias Nectar.Repo
  alias Nectar.Order
  alias Nectar.Country
  alias Nectar.State
  alias Nectar.Product
  alias Nectar.CartManager
  alias Nectar.User

  setup(context) do
    do_setup(context)
  end

  test "checkout flow", %{conn: conn} do

    cart_page_conn = get(conn, checkout_path(conn, :checkout))
    cart = setup_cart(cart_page_conn.assigns.current_order) # create cart for user

    address_page_conn = get(conn, checkout_path(cart_page_conn, :checkout))
    assert html_response(address_page_conn, 200) =~ "Address"

    shipping_page_conn = put(conn, checkout_path(conn, :next), order: valid_address_params)
    assert html_response(shipping_page_conn, 200) =~ "Select your shipping method"

    tax_page_conn = put(conn, checkout_path(conn, :next), order: valid_shipping_params(cart))
    assert html_response(tax_page_conn, 200) =~ "Confirm"

    payment_page_conn = put(conn, checkout_path(conn, :next), order: %{"tax_confirm" => true})
    assert html_response(payment_page_conn, 200) =~ "Select your payment method"

    confirmation_page_conn = put(conn, checkout_path(conn, :next), order: valid_payment_params(cart))
    assert html_response(confirmation_page_conn, 200) =~ "Confirm"

    order_success_page_conn = put(conn, checkout_path(conn, :next), order: %{"confirm" => true})
    assert html_response(order_success_page_conn, 302) =~ "redirected"
  end

  test "checkout flow no payment methods available", %{conn: conn} do
    cart_page_conn = get(conn, checkout_path(conn, :checkout))
    cart = setup_cart(cart_page_conn.assigns.current_order, true) # create cart for user

    address_page_conn = get(conn, checkout_path(cart_page_conn, :checkout))
    assert html_response(address_page_conn, 200) =~ "Address"

    shipping_page_conn = put(conn, checkout_path(conn, :next), order: valid_address_params)
    assert html_response(shipping_page_conn, 200) =~ "Select your shipping method"

    tax_page_conn = put(conn, checkout_path(conn, :next), order: valid_shipping_params(cart))
    assert html_response(tax_page_conn, 200) =~ "Confirm"

    payment_page_conn = put(conn, checkout_path(conn, :next), order: %{"tax_confirm" => true})
    assert html_response(payment_page_conn, 200) =~ "applicable"
  end

  test "checkout flow no shipping methods available", %{conn: conn} do
    cart_page_conn = get(conn, checkout_path(conn, :checkout))
    cart = setup_cart(cart_page_conn.assigns.current_order, true, true) # create cart for user

    address_page_conn = get(conn, checkout_path(cart_page_conn, :checkout))
    assert html_response(address_page_conn, 200) =~ "Address"

    shipping_page_conn = put(conn, checkout_path(conn, :next), order: valid_address_params)
    assert html_response(shipping_page_conn, 200) =~ "we cannot deliver these products at this time to your location."
  end


  test "checkout flow empty cart", %{conn: conn} do
    cart = setup_cart_without_product
    address_page_conn = get(conn, checkout_path(conn, :checkout))
    assert address_page_conn.halted
    assert html_response(address_page_conn, 302) =~ "redirected"
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
      add_count: @max_master_quantity
    }
  }
  @product_attr Map.merge(@product_data, @product_master_variant_data)

  defp setup_cart(cart, skip_payments \\ false, skip_shipping_methods \\ false) do
    unless skip_payments, do: create_payment_methods
    unless skip_shipping_methods, do: create_shipping_methods
    create_taxations
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
    %{"order_shipping_address" => address, "order_billing_address" => address}
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
    shipping_method_ids = Enum.map(shipping_methods, fn(method_name) ->
      Nectar.ShippingMethod.changeset(%Nectar.ShippingMethod{}, %{name: method_name, enabled: true})
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
      Nectar.PaymentMethod.changeset(%Nectar.PaymentMethod{}, %{name: method_name, enabled: true})
      |> Nectar.Repo.insert!
    end)
  end

  defp valid_shipping_params(%Order{"id": _id}) do
    shipping_method_id = create_shipping_methods |> List.first |> Map.get(:id)
    %{"shipping" => %{"shipping_method_id" => shipping_method_id}}
  end

  defp valid_payment_params(%Order{"id": _id}) do
    payment_method_id = create_payment_methods |> List.first |> Map.get(:id)
    %{"payment" => %{"payment_method_id" => payment_method_id}}
  end

  defp do_setup(%{nologin: _} = _context) do
    {:ok, %{conn: conn}}
  end

  defp do_setup(_context) do
    user = Repo.insert!(%User{name: "NotAdmin", email: "not_admin@vinsol.com", encrypted_password: Comeonin.Bcrypt.hashpwsalt("vinsol"), is_admin: false})
    conn = guardian_login(user)
    {:ok, %{conn: conn}}
  end
end
