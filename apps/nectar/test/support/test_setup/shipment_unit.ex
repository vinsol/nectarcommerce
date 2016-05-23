defmodule Nectar.TestSetup.ShipmentUnit do
  alias Nectar.Order
  alias Nectar.Repo
  alias Nectar.TestSetup.Variant, as: VariantSetup

  def create_shipment_units do
    %{variant: variant} = VariantSetup.create_variant
    VariantSetup.add_quantity(variant, 3)
    order = Order.cart_changeset(%Order{}, %{}) |> Repo.insert!
    add_to_cart = Nectar.CartManager.add_to_cart(order, %{"variant_id" => variant.id, "quantity" => 3})
    Nectar.Shipment.Splitter.make_shipment_units(Repo.get(Order, order.id))
  end
end
