defmodule Seed.CreateShippingMethod do
  def seed! do
    shipping_methods = ["regular", "express"]
    Enum.each(shipping_methods, fn(method_name) ->
      Nectar.ShippingMethod.changeset(%Nectar.ShippingMethod{}, %{name: method_name})
      |> Nectar.Repo.insert!
    end)
  end
end
