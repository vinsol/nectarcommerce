defmodule ExShop.Invoice do

  alias ExShop.Order
  alias ExShop.Repo
  import Ecto.Query

  # generate an invoice each for all possible payment methods
  def generate(order) do
    order
    |> create_invoices
  end

  defp create_invoices(%Order{payments: payments} = order) do
    payment_methods = Repo.all(ExShop.PaymentMethod)
    invoices =  Enum.map(payment_methods, fn(p_method) ->
      order
      |> Ecto.build_assoc(:payment_methods)
      |> ExShop.Payments.changeset(%{payment_method_id: p_method.id})
      |> Repo.insert
    end)
    %Order{order | payments: invoices}
  end
end
