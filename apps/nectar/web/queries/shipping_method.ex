defmodule Nectar.Query.ShippingMethod do
  use Nectar.Query, model: Nectar.ShippingMethod

  def enabled_shipping_methods do
    from shipp in Nectar.ShippingMethod,
    where: shipp.enabled
  end

  def enabled_shipping_methods(repo), do: repo.all(enabled_shipping_methods)

end
