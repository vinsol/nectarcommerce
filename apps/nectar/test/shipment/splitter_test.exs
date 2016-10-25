defmodule Nectar.Shipment.SplitterTest do
  use Nectar.ModelCase

  import Nectar.TestSetup.Order, only: [setup_cart: 0, setup_cart_with_multiple_products: 0]

  setup context do
    if context[:use_splitter] do
      setting_name = :shipment_splitter
      Application.put_env(:nectar, setting_name, context[:use_splitter])
      on_exit fn -> Application.delete_env(:nectar, setting_name) end
    end
    :ok
  end

  describe "split/1" do
    test "takes the order and splits it into shipment units" do
      cart = setup_cart |> Nectar.Repo.preload([:line_items])
      shipments = [[op]]   = Nectar.Shipment.Splitter.split(cart)
      assert Enum.count(shipments) == 1
      assert op.__struct__ == Nectar.LineItem
    end

    @tag use_splitter: Nectar.Shipment.Splitter.SplitAll
    test "uses the configured splitter if present" do
      cart = setup_cart_with_multiple_products |> Nectar.Repo.preload([:line_items])
      shipments = Nectar.Shipment.Splitter.split(cart)
      [op] = List.first shipments
      assert Enum.count(shipments) == 2
      assert op.__struct__ == Nectar.LineItem
    end
  end

end
