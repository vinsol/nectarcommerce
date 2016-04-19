defmodule Nectar.TaxCalculator do

  alias Nectar.Order
  alias Nectar.Repo

  def calculate_taxes(%Order{} = order) do
    order
    |> create_tax_adjustments
  end

  defp create_tax_adjustments(%Order{} = order) do
    taxes = Repo.all(Nectar.Tax)
    tax_adjustments = Enum.map(taxes, fn (tax) ->
      order
      |> Ecto.build_assoc(:adjustments)
      |> Nectar.Adjustment.changeset(%{amount: 20.00, tax_id: tax.id})
      |> Repo.insert!
    end)
    %Order{order | adjustments: tax_adjustments}
  end

end
