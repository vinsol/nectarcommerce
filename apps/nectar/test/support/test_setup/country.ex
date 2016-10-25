defmodule Nectar.TestSetup.Country do
  alias Nectar.Repo

  def valid_attrs, do: %{"name" => "Country", "iso" => "Co", "iso3" => "Con", "numcode" => "123"}
  def invalid_attrs, do: %{}

  def create_country!(country_attrs \\ nil) do
    attrs = country_attrs || valid_attrs
    Nectar.Command.Country.insert!(Repo, attrs)
  end

  def create_country(country_attrs \\ nil) do
    attrs = country_attrs || valid_attrs
    Nectar.Command.Country.insert(Repo, attrs)
  end
end
