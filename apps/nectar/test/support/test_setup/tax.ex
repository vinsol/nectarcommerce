defmodule Nectar.TestSetup.Tax do
  alias Nectar.Repo
  @names ["VAT", "GST"]
  def create_taxes(names \\ @names) do
    Enum.each(names, fn(tax_name) ->
      Nectar.Tax.changeset(%Nectar.Tax{}, %{name: tax_name})
      |> Repo.insert!
    end)
  end
end
