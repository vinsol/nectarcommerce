defmodule Seed.CreatePaymentMethod do
  def seed! do
    payment_methods = ["cheque", "stripe", "nectar_wallet"]
    Enum.each(payment_methods, fn(method_name) ->
      Nectar.PaymentMethod.changeset(%Nectar.PaymentMethod{}, %{name: method_name, enabled: true})
      |> Nectar.Repo.insert!
    end)
  end
end
