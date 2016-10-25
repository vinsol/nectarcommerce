defmodule Nectar.Command.Adjustment do
  use Nectar.Command, model: Nectar.Adjustment

  def create_tax_adjustment!(repo, order, tax, calculated_amount) do
    order
    |> Ecto.build_assoc(:adjustments)
    |> Nectar.Adjustment.changeset(%{amount: calculated_amount, tax_id: tax.id})
    |> repo.insert!
  end
end
