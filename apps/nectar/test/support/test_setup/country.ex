defmodule Nectar.TestSetup.Country do
  alias Nectar.Repo

  @country_attrs %{"name" => "Country", "iso" => "Co", "iso3" => "Con", "numcode" => "123"}

  def create_country(country_attrs \\ @country_attrs) do
    Nectar.Country.changeset(%Nectar.Country{}, country_attrs) |> Repo.insert!
  end
end
