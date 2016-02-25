defmodule Seed.CreatePaymentMethod do
  def seed! do
    payment_methods = ["cheque", "stripe"]
    Enum.each(payment_methods, fn(method_name) ->
      ExShop.PaymentMethod.changeset(%ExShop.PaymentMethod{}, %{name: method_name})
      |> ExShop.Repo.insert!
    end)
  end
end
