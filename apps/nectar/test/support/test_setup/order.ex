defmodule Nectar.TestSetup.Order do
  alias Nectar.Repo
  alias Nectar.ShippingMethod
  alias Nectar.PaymentMethod
  alias Nectar.CheckoutManager
  alias Nectar.Order
  alias Nectar.LineItem
  alias Nectar.Product
  alias Nectar.Country
  alias Nectar.State

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

  defp create_order do
    Order.cart_changeset(%Order{}, %{})
    |> Repo.insert!
  end

  def create_order_with_line_items do
    line_item = create_line_item_with_product_quantity(2) |> Repo.insert!
    order_id = line_item.order_id
    order = Repo.get(Order, order_id) |> Repo.preload([:line_items])

    {_, c_addr} = move_cart_to_address_state(order)
    {_status, c_shipp} = move_cart_to_shipping_state(c_addr)
    {_status, c_tax} = move_cart_to_tax_state(c_shipp)
    {_status, c_payment} = move_cart_to_payment_state(c_tax)
    {status,  c_confirm} = move_cart_to_confirmation_state(c_payment)

    {:ok, line_item: line_item}
  end

  defp create_product do
    product = Product.create_changeset(%Product{}, @product_attr)
    |> Repo.insert!
    product
  end

  defp create_product_with_variant do
    product = create_product
    product
    |> build_assoc(:variants)
    |> Variant.create_variant_changeset(@valid_variant_attrs)
    |> Repo.insert!
    product
  end

  defp create_product_with_oos_variant do
    product = create_product
    product
    |> build_assoc(:variants)
    |> Variant.create_variant_changeset(@valid_variant_attrs)
    |> Repo.insert!
    Repo.one(Product.product_with_variants(product.id))
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

  defp create_line_item_with_out_of_stock_product do
    oos_variant = List.first create_product_with_oos_variant.variants
    oos_variant
    |> Ecto.build_assoc(:line_items)
    |> LineItem.changeset(%{order_id: create_order.id, add_quantity: 3})
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
      ShippingMethod.changeset(%ShippingMethod{}, %{name: method_name})
      |> Repo.insert!
    end)
  end

  defp create_payment_methods do
    payment_methods = ["cheque", "Call With a card"]
    Enum.map(payment_methods, fn(method_name) ->
      PaymentMethod.changeset(%PaymentMethod{}, %{name: method_name})
      |> Repo.insert!
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
