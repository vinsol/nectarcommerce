defmodule ExShop.CheckoutManagerTest do
  use ExShop.ModelCase

  alias ExShop.Order
  alias ExShop.CheckoutManager
  alias ExShop.Country
  alias ExShop.State
  alias ExShop.Product
  alias ExShop.CartManager

  test "assert cart is not empty before each step" do
    cart = setup_cart_without_product
    {status, order} = CheckoutManager.next(cart, %{})
    assert status == :error
    assert order.errors[:line_items] == "Please add some item to your cart to proceed"
  end

  test "move to address state missing parameters" do
    {status, order} = CheckoutManager.next(setup_cart, %{})
    assert status == :error
    assert order.model.state == "cart"
    assert order.errors[:order_billing_address] == "can't be blank"
    assert order.errors[:order_shipping_address] == "can't be blank"
  end

  test "move to address state invalid parameters" do
    {status, order} = CheckoutManager.next(setup_cart, %{"order_shipping_address" =>  %{"address_line_1" => "asd", "country_id" => 1},
                                                         "order_billing_address" => %{}})
    assert status == :error
    assert order.model.state == "cart"
    assert order.errors == []
    assert order.changes[:order_shipping_address].errors[:address_line_1] == {"should be at least %{count} character(s)", [count: 10]}
    assert order.changes[:order_billing_address].errors[:country_id] == "can't be blank"
  end

  test "move to address state with valid parameters" do
    {status, order} = CheckoutManager.next(setup_cart, valid_address_params)
    assert status == :ok
    assert order.state == "address"
    assert order.order_shipping_address.id
    assert order.order_billing_address.id
  end

  test "move to address state with same_as_shipping copies creates two seperate addresses with same data" do
    {status, order} = CheckoutManager.next(setup_cart, valid_address_params_same_as_billing)
    assert status == :ok
    assert order.state == "address"
    assert order.order_shipping_address.address_id
    assert order.order_shipping_address.address_id
    assert order.order_shipping_address.address_id == order.order_billing_address.address_id
  end

  test "move to address state invalid parameters with same_as billing" do
    {status, order} = CheckoutManager.next(setup_cart, %{"order_shipping_address" =>  %{"address_line_1" => "asd", "country_id" => 1},
                                                         "order_billing_address" => %{}, "same_as_billing" => true})
    assert status == :error
    assert order.model.state == "cart"
    assert order.errors == []
    assert order.changes[:order_billing_address].errors[:country_id] == "can't be blank"
  end


  test "move to shipping state missing parameters" do
    cart = setup_cart
    {:ok, cart_in_addr_state} = move_cart_to_address_state(cart)
    {status, order} = CheckoutManager.next(cart_in_addr_state, %{})
    assert status == :error
    assert order.errors[:shipping] == "can't be blank"
  end


  test "move to shipping state valid parameters" do
    {_, c_addr} = move_cart_to_address_state(setup_cart)
    {status, c_shipp} = move_cart_to_shipping_state(c_addr)

    assert status == :ok
    assert c_shipp.state == "shipping"
  end

  test "move to shipping state valid parameters adds tax adjustments" do
    {_, c_addr} = move_cart_to_address_state(setup_cart)
    {_status, c_shipp} = move_cart_to_shipping_state(c_addr)

    assert Enum.count(c_shipp.adjustments) == 2
  end

  test "move to tax state missing parameters" do
    {_, c_addr} = move_cart_to_address_state(setup_cart)
    {_, c_shipp} = move_cart_to_shipping_state(c_addr)
    {status, failed_change} = CheckoutManager.next(c_shipp, %{})
    assert status == :error
    assert failed_change.errors[:tax_confirm] == "Please confirm to proceed"
  end

  test "move to tax state valid parameters" do
    {_, c_addr} = move_cart_to_address_state(setup_cart)
    {_, c_shipp} = move_cart_to_shipping_state(c_addr)
    {status, c_tax} = move_cart_to_tax_state(c_shipp)
    assert status == :ok
    assert c_tax.state == "tax"
  end

  test "move to tax state valid parameters but no taxes present" do
    {_, c_addr} = move_cart_to_address_state(setup_cart)
    # delete taxes before moving to shipping since it calculates the taxes.
    Repo.delete_all(ExShop.Tax)
    {_, c_shipp} = move_cart_to_shipping_state(c_addr)
    {status, c_tax} = move_cart_to_tax_state(c_shipp)
    assert status == :ok
    assert c_tax.state == "tax"
  end

  test "move to tax state valid parameters but no taxes present calculates the order total" do
    {_, c_addr} = move_cart_to_address_state(setup_cart)
    # delete taxes before moving to shipping since it calculates the taxes.
    Repo.delete_all(ExShop.Tax)
    {_, c_shipp} = move_cart_to_shipping_state(c_addr)
    {status, c_tax} = move_cart_to_tax_state(c_shipp)
    assert status == :ok
    assert c_tax.state == "tax"
    assert c_tax.total > 0
  end

  test "move to tax state calculates the order total" do
    {_, c_addr} = move_cart_to_address_state(setup_cart)
    {_status, c_shipp} = move_cart_to_shipping_state(c_addr)
    {_status, c_tax} = move_cart_to_tax_state(c_shipp)
    assert c_tax.total
  end

  test "move to payment state missing parameters" do
    {_, c_addr} = move_cart_to_address_state(setup_cart)
    {_status, c_shipp} = move_cart_to_shipping_state(c_addr)
    {_status, c_tax} = move_cart_to_tax_state(c_shipp)
    {status, c_payment} = CheckoutManager.next(c_tax, %{})
    assert status == :error
    assert c_payment.errors[:payment] == "can't be blank"
  end

  test "move to payment state valid parameters" do
    {_, c_addr} = move_cart_to_address_state(setup_cart)
    {_status, c_shipp} = move_cart_to_shipping_state(c_addr)
    {_status, c_tax} = move_cart_to_tax_state(c_shipp)
    {status, c_payment} = move_cart_to_payment_state(c_tax)
    assert status == :ok
    assert c_payment.state == "payment"
  end

  test "move to confirmation state missing parameters" do
    {_, c_addr} = move_cart_to_address_state(setup_cart)
    {_status, c_shipp} = move_cart_to_shipping_state(c_addr)
    {_status, c_tax} = move_cart_to_tax_state(c_shipp)
    {_status, c_payment} = move_cart_to_payment_state(c_tax)
    {status,  c_confirm} = CheckoutManager.next(c_payment, %{})
    assert status == :error
    assert c_confirm.errors[:confirm] == "Please confirm to finalise the order"
  end

  test "move to confirmation state valid parameters" do
    {_, c_addr} = move_cart_to_address_state(setup_cart)
    {_status, c_shipp} = move_cart_to_shipping_state(c_addr)
    {_status, c_tax} = move_cart_to_tax_state(c_shipp)
    {_status, c_payment} = move_cart_to_payment_state(c_tax)
    {status,  c_confirm} = move_cart_to_confirmation_state(c_payment)
    assert status == :ok
    assert c_confirm.state == "confirmation"
  end

  test "cannot move back from confirmation state" do
    {_, c_addr} = move_cart_to_address_state(setup_cart)
    {_status, c_shipp} = move_cart_to_shipping_state(c_addr)
    {_status, c_tax} = move_cart_to_tax_state(c_shipp)
    {_status, c_payment} = move_cart_to_payment_state(c_tax)
    {status,  c_confirm} = move_cart_to_confirmation_state(c_payment)
    assert status == :ok
    assert c_confirm.state == "confirmation"
    {:ok, backed_order} = CheckoutManager.back(c_confirm)
    assert backed_order.state == c_confirm.state
  end

  test "moving back from payment state goes to tax state" do
    {_, c_addr} = move_cart_to_address_state(setup_cart)
    {_status, c_shipp} = move_cart_to_shipping_state(c_addr)
    {_status, c_tax} = move_cart_to_tax_state(c_shipp)
    {status, c_payment} = move_cart_to_payment_state(c_tax)
    assert status == :ok
    assert c_payment.state == "payment"
    {:ok, backed_order} = CheckoutManager.back(c_payment)
    assert backed_order.state == "tax"
  end

  test "moving back from tax state goes to shipping state" do
    {_, c_addr} = move_cart_to_address_state(setup_cart)
    {_status, c_shipp} = move_cart_to_shipping_state(c_addr)
    {status, c_tax} = move_cart_to_tax_state(c_shipp)
    assert status == :ok
    assert c_tax.state == "tax"
    {:ok, backed_order} = CheckoutManager.back(c_tax)
    assert backed_order.state == "shipping"
  end

  test "moving back from shipping state goes to address state" do
    {_, c_addr} = move_cart_to_address_state(setup_cart)
    {status, c_shipp} = move_cart_to_shipping_state(c_addr)
    assert status == :ok
    assert c_shipp.state == "shipping"
    {:ok, backed_order} = CheckoutManager.back(c_shipp)
    assert backed_order.state == "address"
  end

  test "moving back from address state goes to cart state" do
    {status, c_addr} = move_cart_to_address_state(setup_cart)
    assert status == :ok
    assert c_addr.state == "address"
    {:ok, backed_order} = CheckoutManager.back(c_addr)
    assert backed_order.state == "cart"
  end

  test "cannot move back from cart state" do
    cart = setup_cart
    assert cart.state == "cart"
    {:ok, backed_order} = CheckoutManager.back(cart)
    assert backed_order.state == "cart"
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
  @master_cost_price Decimal.new("30.00")
  @max_master_quantity 3
  @product_master_variant_data %{
    master: %{
      cost_price: @master_cost_price,
      add_count: @max_master_quantity
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
    payment_methods = ["cheque", "Call With a card"]
    Enum.map(payment_methods, fn(method_name) ->
      ExShop.PaymentMethod.changeset(%ExShop.PaymentMethod{}, %{name: method_name})
      |> ExShop.Repo.insert!
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
