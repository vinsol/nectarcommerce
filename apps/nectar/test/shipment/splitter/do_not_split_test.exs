defmodule Nectar.Shipment.Splitter.DoNotSplitTest do
  use Nectar.ModelCase

  alias Nectar.Order
  alias Nectar.CartManager
  alias Nectar.Product

  test "it splits the line items into 1 shipment unit" do
    cart = setup_cart_with_one_product |> Repo.preload([:line_items])
    [shipment_unit] = Nectar.Shipment.Splitter.DoNotSplit.split(cart)
    assert Enum.count(shipment_unit.line_items) == Enum.count(cart.line_items)
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

  defp setup_cart_with_one_product do
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

  defp setup_cart_without_product do
    Order.cart_changeset(%Order{}, %{})
    |> Repo.insert!
  end

end
