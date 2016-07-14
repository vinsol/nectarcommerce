defmodule Nectar.Command.ShippingMethod do
  use Nectar.Command, model: Nectar.ShippingMethod
  import Ecto.Query

  def make_active_enabled_and_disable_other(repo, params) do
    enabled_shipping_method_ids =
      Enum.filter(params, fn
        ({_, %{"enabled" => "true"}}) -> true
        ({_, %{"enabled" => "false"}}) -> false
      end) |> Enum.map(fn({_, %{"id" => id}}) -> id end)
    repo.transaction(fn ->
      repo.update_all(enable(enabled_shipping_method_ids), [])
      repo.update_all(disable_other_than(enabled_shipping_method_ids), [])
    end)
  end

  defp enable(shipping_method_ids) do
    from shipping in Nectar.ShippingMethod,
    where: shipping.id in ^shipping_method_ids,
    update: [set: [enabled: true]]
  end

  defp disable_other_than(shipping_method_ids) do
    from shipping in Nectar.ShippingMethod,
    where: not shipping.id in ^shipping_method_ids,
    update: [set: [enabled: false]]
  end

end
