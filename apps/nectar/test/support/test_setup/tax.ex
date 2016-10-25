defmodule Nectar.TestSetup.Tax do
  alias Nectar.Repo

  def valid_attrs, do: %{name: "tax_name"}
  def invalid_attrs, do: %{}

  @names ["VAT", "GST"]
  def create_taxes(names \\ @names) do
    Enum.each(names, fn(tax_name) ->
      Nectar.Tax.changeset(%Nectar.Tax{}, %{name: tax_name})
      |> Repo.insert!
    end)
  end
end
