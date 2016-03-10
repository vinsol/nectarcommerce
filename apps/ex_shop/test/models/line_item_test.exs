defmodule ExShop.LineItemTest do
  use ExShop.ModelCase

  alias ExShop.Repo
  alias ExShop.LineItem
  alias ExShop.Order
  alias ExShop.Product
  alias ExShop.Variant
  alias ExShop.Country
  alias ExShop.State
  alias ExShop.CheckoutManager

  @order_attr   %{}

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
  @variant_option_value_attrs %{
    variant_option_values: [
      %{
        option_value_id: "1",
        option_type_id: "1"
      }
    ]
  }

  @product_attr Map.merge(@product_data, @product_master_variant_data) |> Map.merge(@variant_option_value_attrs)

  @valid_variant_attrs %{
    cost_price: "120.5",
    discontinue_on: Ecto.Date.utc,
    height: "120.5", weight: "120.5", width: "120.5",
    sku: "URG123"
  }

  @tag :pending
  test "LineItem Mgmt with variants and not only master variant" do
    assert false
  end

  test "line item cannot add master variant if other variants present" do
    changeset = create_line_item_with_invalid_master_variant
    refute changeset.valid?
    assert changeset.errors[:variant] == "cannot add master variant to cart when other variants are present."
  end

  test "line item with available quantity" do
    changeset = create_line_item_with_product_quantity(2)
    assert changeset.errors == []
  end

  test "line item with unavailable quantity" do
    changeset = create_line_item_with_product_quantity(@max_master_quantity + 2)
    refute changeset.valid?
    assert changeset.errors[:quantity] == "only #{@max_master_quantity} available"
  end

  test "line item with 0 quantity" do
    changeset = create_line_item_with_product_quantity(0)
    refute changeset.valid?
    assert changeset.errors[:quantity] == {"must be greater than %{count}", [count: 0]}
  end

  test "adding product calculates total" do
    changeset = create_line_item_with_product_quantity(2)
    assert changeset.changes[:total] == Decimal.mult(Decimal.new("2"), @master_cost_price)
  end

  test "line item for non existent order" do
    changeset = create_line_item_with_product(-1)
    assert changeset.valid?
    {status, updated_changeset} = Repo.insert changeset
    assert status == :error
    assert updated_changeset.errors[:order_id] == "does not exist"
  end

  test "query by order" do
    line_item = create_line_item_with_product_quantity(2)
    |> Repo.insert!
    order = Repo.get Order, line_item.order_id
    assert line_item.id in Repo.all(from ln in LineItem.in_order(LineItem, order), select: ln.id)
  end

  test "query with product" do
    line_item = create_line_item_with_product_quantity(2)
    |> Repo.insert!
    variant = Repo.get Variant, line_item.variant_id
    assert line_item.id in Repo.all(from ln in LineItem.with_variant(LineItem, variant), select: ln.id)
  end

  test "cancel fulfillment does not work if order is not confirmed" do
    line_item = create_line_item_with_product_quantity(2) |> Repo.insert!
    order_id = line_item.order_id
    order = ExShop.Repo.get(ExShop.Order, order_id)
    {status, changeset} = ExShop.LineItem.cancel_fullfillment(%ExShop.LineItem{line_item|order: order})
    assert status == :error
    assert changeset.errors[:fullfilled] == "Order should be in confirmation state before updating the fullfillment status"
  end

  test "cancel fullfillment on confirmed order updates the order status and total" do
    line_item = create_line_item_with_product_quantity(2) |> Repo.insert!
    order_id = line_item.order_id
    order = ExShop.Repo.get(ExShop.Order, order_id) |> Repo.preload([:line_items])
    assert order.state == "cart"
    assert Enum.count(order.line_items) == 1

    {_, c_addr} = move_cart_to_address_state(order)
    {_status, c_shipp} = move_cart_to_shipping_state(c_addr)
    {_status, c_tax} = move_cart_to_tax_state(c_shipp)
    {_status, c_payment} = move_cart_to_payment_state(c_tax)
    {status,  c_confirm} = move_cart_to_confirmation_state(c_payment)

    assert status == :ok
    assert c_confirm.state == "confirmation"
    assert c_confirm.confirmation_status

    {_status, line_item} = ExShop.LineItem.cancel_fullfillment(%ExShop.LineItem{line_item|order: c_confirm})
    refute line_item.fullfilled

    updated_order = ExShop.Repo.get(ExShop.Order, order_id)
    # helper method for calculating the sum of adjustments.
    prod_diff = fn (order) -> Decimal.sub(order.total, order.product_total) end

    # order cancelled because only 1 line item in the order
    refute updated_order.confirmation_status
    # the order total changed
    assert updated_order.total != c_confirm.total
    # the product total also changed
    assert updated_order.product_total != c_confirm.product_total
    # the total of adjustments remain the same (product_total + adjustments = total)
    assert Decimal.compare(prod_diff.(updated_order), prod_diff.(c_confirm)) == Decimal.new("0")
  end


  defp create_order do
    Order.cart_changeset(%Order{}, %{})
    |> Repo.insert!
  end

  defp create_product do
    product = Product.create_changeset(%Product{}, @product_attr)
    |> Repo.insert!
    product
  end

  defp create_product_with_variant do
    product = create_product
    #master_variant = product.master
    product
    |> build_assoc(:variants)
    |> Variant.create_variant_changeset(@valid_variant_attrs)
    |> Repo.insert!
    product
  end

  defp create_line_item_with_product(order_id \\ nil) do
    create_product.master
    |> Ecto.build_assoc(:line_items)
    |> LineItem.create_changeset(%{order_id: order_id || create_order.id})
  end

  defp create_line_item_with_invalid_master_variant do
    create_product_with_variant.master
    |> Ecto.build_assoc(:line_items)
    |> LineItem.create_changeset(%{order_id: create_order.id})
  end

  defp create_line_item_with_product_quantity(quantity) do
    create_line_item_with_product
    |> LineItem.quantity_changeset(%{add_quantity: quantity})
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
