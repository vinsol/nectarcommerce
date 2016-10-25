defmodule Nectar.Shipment.Splitter.DoNotSplitTest do
  use Nectar.ModelCase

  import Nectar.TestSetup.Order, only: [setup_cart: 0, setup_cart_with_multiple_products: 0]

  test "it splits the line items into 1 shipment unit" do
    cart = setup_cart |> Repo.preload([:line_items])
    [shipment_unit] = Nectar.Shipment.Splitter.DoNotSplit.split(cart)
    assert Enum.count(shipment_unit) == Enum.count(cart.line_items)
  end

  test "it splits multiple line items into 1 shipment unit" do
    cart = setup_cart_with_multiple_products |> Repo.preload([:line_items])
    [shipment_unit] = Nectar.Shipment.Splitter.DoNotSplit.split(cart)
    assert Enum.count(shipment_unit) == Enum.count(cart.line_items)
  end

end
