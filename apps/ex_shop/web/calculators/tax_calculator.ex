defmodule ExShop.TaxCalculator do

  alias ExShop.Order
  alias ExShop.Repo
  import Ecto.Query

  def calculate_taxes(%Order{} = order) do
    order
    |> create_tax_adjustments
  end

  defp create_tax_adjustments(%Order{} = order) do
    taxes = Repo.all(ExShop.Tax)
    tax_adjustments = Enum.map(taxes, fn (tax) ->
      order
      |> Ecto.build_assoc(:adjustments)
      |> ExShop.Adjustment.changeset(%{amount: 20.00, tax_id: tax.id})
      |> Repo.insert!
    end)
    %Order{order | adjustments: tax_adjustments}
  end

end
