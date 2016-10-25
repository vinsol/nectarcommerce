defmodule Nectar.Query.PaymentMethod do
  use Nectar.Query, model: Nectar.PaymentMethod

  def enabled_payment_methods do
    from pay in Nectar.PaymentMethod,
    where: pay.enabled
  end

  def enabled_payment_methods(repo), do: repo.all(enabled_payment_methods)
end
