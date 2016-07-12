defmodule Nectar.TestSetup.Country do
  alias Nectar.Repo

  def valid_attrs, do: %{"name" => "Country", "iso" => "Co", "iso3" => "Con", "numcode" => "123"}
  def invalid_attrs, do: %{}

  def create_country!(country_attrs \\ nil) do
    attrs = country_attrs || valid_attrs
    Nectar.Country.changeset(%Nectar.Country{}, attrs) |> Repo.insert!
  end

  def create_country(country_attrs \\ nil) do
    attrs = country_attrs || valid_attrs
    Nectar.Country.changeset(%Nectar.Country{}, attrs) |> Repo.insert
  end
end
