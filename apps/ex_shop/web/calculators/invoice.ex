defmodule ExShop.Invoice do

  alias ExShop.Order
  alias ExShop.Repo

  # generate an invoice each for all possible payment methods
  def generate_applicable_payment_invoices(order) do
    order
    |> create_invoices
  end

  defp create_invoices(%Order{} = _order) do
    payment_methods = Repo.all(ExShop.PaymentMethod.enabled_payment_methods)
    Enum.map(payment_methods, fn(p_method) ->
      p_method
      |> Map.from_struct
      |> Map.drop([:__meta__, :payments])
    end)
  end
end
