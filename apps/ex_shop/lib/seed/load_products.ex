defmodule Seed.LoadProducts do
  def seed! do
    # Enum.each(products, fn(product_params) ->
    #   ExShop.NotProduct.changeset(%ExShop.NotProduct{}, product_params)
    #   |> ExShop.Repo.insert!
    # end)
  end

  defp products do
    [
      %{name: "TShirt", quantity: 2, cost: 4.00},
      %{name: "Pant",   quantity: 2, cost: 2.00},
      %{name: "Shoes",  quantity: 1, cost: 3.00},
    ]
  end
end
