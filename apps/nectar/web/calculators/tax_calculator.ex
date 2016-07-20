defmodule Nectar.TaxCalculator do

  alias Nectar.Order
  alias Nectar.Repo

  def calculate_taxes(repo, order) do
    taxes = Nectar.Query.Tax.all(repo)
    tax_adjustments = Enum.map(taxes, fn (tax) ->
      Nectar.Command.Adjustment.create_tax_adjustment!(repo, order, tax, 20.00)
    end)
  end

end
