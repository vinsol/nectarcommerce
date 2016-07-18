defmodule Nectar.Command.State do
  use Nectar.Command, model: Nectar.State

  def insert_for_country(repo, country, params) do
    country
    |> Ecto.build_assoc(:states)
    |> Nectar.State.changeset(params)
    |> repo.insert
  end
end
