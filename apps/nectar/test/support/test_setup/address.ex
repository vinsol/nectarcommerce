defmodule Nectar.TestSetup.Address do
  def valid_attrs, do: %{address_line_1: "address line", address_line_2: "address line 2", country_id: -1, state_id: -1}
  def invalid_attrs, do: %{address_line_1: "ad", address_line_2: "add"}
  def valid_attrs_with_country_and_state! do
    {:ok, country} = Nectar.TestSetup.Country.create_country
    state = Nectar.TestSetup.State.create_state(country)
    valid_attrs
    |> Map.put(:country_id, country.id)
    |> Map.put(:state_id, state.id)
  end


end
