defmodule Nectar.Command.ShippingMethod do
  use Nectar.Command, model: Nectar.ShippingMethod
  import Ecto.Query

  def enable(shipping_method_ids) do
    from shipping in Nectar.ShippingMethod,
    where: shipping.id in ^shipping_method_ids,
    update: [set: [enabled: true]]
  end

  def disable_other_than(shipping_method_ids) do
    from shipping in Nectar.ShippingMethod,
    where: not shipping.id in ^shipping_method_ids,
    update: [set: [enabled: false]]
  end

end
