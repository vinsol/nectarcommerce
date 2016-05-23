defmodule Nectar.TestSetup.State do
  alias Nectar.Repo

  @default_state_attrs %{name: "State", abbr: "ST"}

  def create_state(country, state_attrs \\ @default_state_attrs) do
    Nectar.State.changeset(%Nectar.State{}, Map.put_new(state_attrs, :country_id, country.id)) |> Repo.insert!
  end

end
