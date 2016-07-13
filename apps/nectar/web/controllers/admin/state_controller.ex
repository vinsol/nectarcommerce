defmodule Nectar.Admin.StateController do
  use Nectar.Web, :admin_controller

  alias Nectar.Country
  alias Nectar.State

  plug :scrub_params, "state" when action in [:create]
  plug :load_country when action in [:create]

  def create(conn, %{"state" => state_params}) do
    country = conn.assigns[:country]
    changeset =
      country
      |> build_assoc(:states)
      |> State.changeset(state_params)
    case Repo.insert(changeset) do
      {:ok, state} ->
        conn
        |> put_status(201)
        |> render("state.json", state: state)
      {:error, changeset} ->
        conn
        |> put_status(422)
        |> render("error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    state = Repo.get!(State, id)
    Repo.delete!(state)
    conn
    |> put_status(:no_content)
    |> json(nil)
  end

  defp load_country(conn, _params) do
    country_id = conn.params["country_id"]
    assign(conn, :country, Repo.get!(Country, country_id))
  end

end
