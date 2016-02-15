defmodule ExShop.ShippingCalculator do
  alias ExShop.Order
  alias ExShop.Repo
  import Ecto.Query

  # generate all possible shippings
  def calculate_shippings(%Order{} = order) do
    order
    |> create_shipping
    |> create_shipping_adjustment
  end

  defp create_shipping(order) do
    shipping_methods = Repo.all(ExShop.ShippingMethod)
    shippings = Enum.map(shipping_methods, fn (shipping_method) ->
      order
      |> Ecto.build_assoc(:shippings)
      |> ExShop.Shipping.changeset(%{"shipping_method_id" => shipping_method.id})
      |> Repo.insert
    end)
    %ExShop.Order{order|shippings: shippings}
  end

  defp create_shipping_adjustment(order) do
    shippings = Enum.map(order.shippings, fn (shipping) ->
      order
      |> Ecto.build_assoc(:adjustment)
      |> ExShop.Adjustment.changeset(%{amount: 10.00, shipping_id: shipping.id})
      |> Repo.insert
    end)
  end
end
