defmodule Seed.CreateTax do
  def seed! do
    taxes = ["VAT", "GST"]
    Enum.each(taxes, fn(tax_name) ->
      Nectar.Tax.changeset(%Nectar.Tax{}, %{name: tax_name})
      |> Nectar.Repo.insert!
    end)
  end

end
