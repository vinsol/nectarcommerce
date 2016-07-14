defmodule Nectar.Command.PaymentMethod do
  use Nectar.Command, model: Nectar.PaymentMethod
  import Ecto.Query

  def enable(repo, payment_method_ids) do
    from payment in Nectar.PaymentMethod,
    where: payment.id in ^payment_method_ids,
    update: [set: [enabled: true]]
  end

  def disable_other_than(repo, payment_method_ids) do
    from payment in Nectar.PaymentMethod,
    where: not payment.id in ^payment_method_ids,
    update: [set: [enabled: false]]
  end

end
