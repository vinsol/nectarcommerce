defmodule Nectar.Command.PaymentMethod do
  use Nectar.Command, model: Nectar.PaymentMethod
  import Ecto.Query

  def make_active_enabled_and_disable_other(repo, params) do
    enabled_payment_method_ids =
      Enum.filter(params, fn
        ({_, %{"enabled" => "true"}}) -> true
        ({_, %{"enabled" => "false"}}) -> false
      end) |> Enum.map(fn({_, %{"id" => id}}) -> id end)
    repo.transaction(fn ->
      repo.update_all(enable(enabled_payment_method_ids), [])
      repo.update_all(disable_other_than(enabled_payment_method_ids), [])
    end)
  end

  defp enable(payment_method_ids) do
    from payment in Nectar.PaymentMethod,
    where: payment.id in ^payment_method_ids,
    update: [set: [enabled: true]]
  end

  defp disable_other_than(payment_method_ids) do
    from payment in Nectar.PaymentMethod,
    where: not payment.id in ^payment_method_ids,
    update: [set: [enabled: false]]
  end

end
