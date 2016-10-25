defmodule Nectar.TestSetup.ZoneMember do
  # all setup for zonemember here
  def attrs_with_country do
    country = Nectar.TestSetup.Country.create_country!
    %{zoneable_id: country.id}
  end
end
