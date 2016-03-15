defmodule Seed.CreatePaymentMethod do
  def seed! do
    payment_methods = ["cheque", "stripe", "braintree"]
    Enum.each(payment_methods, fn(method_name) ->
      Nectar.PaymentMethod.changeset(%Nectar.PaymentMethod{}, %{name: method_name})
      |> Nectar.Repo.insert!
    end)
  end
end
