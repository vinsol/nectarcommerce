defmodule Nectar.Invoice do

  alias Nectar.Order
  alias Nectar.Repo

  # generate an invoice each for all possible payment methods
  def generate_applicable_payment_invoices(repo, order) do
    order
    |> create_invoices(repo)
  end

  defp create_invoices(%Order{} = _order, repo) do
    payment_methods = Nectar.Query.PaymentMethod.enabled_payment_methods(repo)
    Enum.map(payment_methods, fn(p_method) ->
      p_method
      |> Map.from_struct
      |> Map.drop([:__meta__, :payments])
    end)
  end
end
