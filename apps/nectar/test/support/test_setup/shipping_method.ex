defmodule Nectar.TestSetup.ShippingMethod do
  alias Nectar.Repo

  @names ["regular", "express"]

  def create_shipping_methods(names \\ @names, enabled \\ true)

  def create_shipping_methods(names, enabled) when is_list(names) do
    Enum.map(names, fn (name) -> create_shipping_methods(name, enabled) end)
  end

  def create_shipping_methods(name, enabled) do
    Nectar.ShippingMethod.changeset(%Nectar.ShippingMethod{}, %{name: name, enabled: enabled}) |> Repo.insert!
  end

end
