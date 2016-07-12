defmodule Nectar.TestSetup.State do
  alias Nectar.Repo

  @default_state_attrs %{name: "State", abbr: "ST", country_id: -1}

  def valid_attrs, do: @default_state_attrs

  def create_state(country, state_attrs \\ @default_state_attrs) do
    Nectar.State.changeset(%Nectar.State{}, Map.put(state_attrs, :country_id, country.id)) |> Repo.insert!
  end

end
