alias ExShop.Repo
defmodule Seed.LoadCountry do

  def seed!() do
    Enum.each(Worldly.Country.all, fn(ag) -> load_country_data(ag) end)
  end

  def load_country_data(country) do
    change = ExShop.Country.changeset(%ExShop.Country{}, to_param(country))
    inserted_country = Repo.insert!(change)
    if country.has_regions do
      Enum.each(Worldly.Region.regions_for(country), fn(rg) -> load_state_data(inserted_country, rg) end)
    end
  end

  def load_state_data(country, state) do
    country
    |> Ecto.build_assoc(:states, to_param(state))
    |> Repo.insert!
  end

  defp to_param(%Worldly.Country{name: name, alpha_2_code: iso, alpha_3_code: iso3, numeric_code: numcode, has_regions: has_states}) do
    %{name: name, iso: iso, iso3: iso3, numcode: numcode, has_states: has_states, iso_name: String.upcase(name)}
  end
  defp to_param(%Worldly.Region{code: abbr, name: name}) do
    %{abbr: to_string(abbr), name: to_string(name)}
  end
end
