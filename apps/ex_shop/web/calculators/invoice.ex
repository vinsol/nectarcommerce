defmodule ExShop.Invoice do

  alias ExShop.Order
  alias ExShop.Repo

  # generate an invoice each for all possible payment methods
  def generate(order) do
    order
    |> create_invoices
  end

  defp create_invoices(%Order{} = order) do
    payment_methods = Repo.all(ExShop.PaymentMethod)
    invoices =  Enum.map(payment_methods, fn(p_method) ->
      order
      |> Ecto.build_assoc(:payments)
      |> ExShop.Payment.changeset(%{payment_method_id: p_method.id})
      |> Repo.insert!
    end)
    %Order{order | payments: invoices}
  end
end
