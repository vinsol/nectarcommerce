defmodule ExShop.CheckoutManagerTest do
  use ExShop.ModelCase

  alias ExShop.Order
  alias ExShop.CheckoutManager
  alias ExShop.Country
  alias ExShop.State

  setup do
    create_shipping_methods
    create_taxations
  end

  test "move to address state missing parameters" do
    {status, order} = CheckoutManager.next(setup_cart, %{})
    assert status == :error
    assert order.model.state == "cart"
    assert order.errors[:billing_address] == "can't be blank"
    assert order.errors[:shipping_address] == "can't be blank"
  end

  test "move to address state invalid parameters" do
    {status, order} = CheckoutManager.next(setup_cart, %{"shipping_address" => %{"address_line_1" => "asd", "country_id" => 1}, "billing_address" => %{}})
    assert status == :error
    assert order.model.state == "cart"
    assert order.errors == []
    assert order.changes[:shipping_address].errors == [address_line_1: {"should be at least %{count} character(s)",
                                                                        [count: 10]}, address_line_2: "can't be blank",
                                                       state_id: "can't be blank"]
    assert order.changes[:billing_address].errors == [address_line_1: "can't be blank", address_line_2: "can't be blank",
                                                       country_id: "can't be blank", state_id: "can't be blank"]
  end

  test "move to address state with valid parameters" do
    {status, order} = CheckoutManager.next(setup_cart, valid_address_params)
    assert status == :ok
    assert order.state == "address"
  end

  test "move to address state with valid parameters creates shippings" do
    {status, order} = CheckoutManager.next(setup_cart, valid_address_params)
    assert status == :ok
    assert Enum.count(order.shippings) == 2
    # assert none of the shipping is selected.
    refute Enum.reduce(order.shippings, false, &(&1.selected || &2))
  end

  test "move to shipping state missing parameters" do
    cart = setup_cart
    {:ok, cart_in_addr_state} = move_cart_to_address_state(cart)
    {status, order} = CheckoutManager.next(cart_in_addr_state, %{})
    assert status == :error
    assert order.errors[:shippings] == "Please select atleast one shipping method"
  end

  defp move_cart_to_address_state(cart) do
    CheckoutManager.next(cart, valid_address_params)
  end
  defp move_cart_to_shipping_state(cart) do
    CheckoutManager.next(cart, valid_shipping_params(cart))
  end
  defp valid_shipping_params(cart) do
    [_, %{__struct__: _,id: shipping_id}] = cart.shippings
    %{"shippings" => %{"id" => shipping_id, "selected": true}}
  end

  test "move to shipping state valid parameters" do
    {_, c_addr} = move_cart_to_address_state(setup_cart)
    {status, c_shipp} = move_cart_to_address_state(setup_cart)
    assert status == :ok
    assert c_shipp.state == "shipping"
  end

  test "move to shipping state valid parameters adds tax adjustments" do
    assert false
  end


  test "move to tax state missing parameters" do
    assert false
  end

  test "move to tax state valid parameters" do
    assert false
  end

  test "move to payment state missing parameters" do
    assert false
  end

  test "move to payment state valid parameters" do
    assert false
  end

  test "move to confirmation state missing parameters" do
    assert false
  end

  test "move to confirmation state valid parameters" do
    assert false
  end


  defp setup_cart do
    create_shipping_methods
    create_taxations
    Order.cart_changeset(%Order{}, %{})
    |> Repo.insert!
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

end
