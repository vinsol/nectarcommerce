defmodule Nectar.TestSetup.Zone do
  def valid_attrs  , do: %{name: "NA", description: "TEST", type: "Country"}
  def invalid_attrs, do: %{name: "NA", description: "FAIL TEST", type: "DoesNotExist"}
  def create!, do: Nectar.Command.Zone.insert!(Nectar.Repo, valid_attrs)
end
