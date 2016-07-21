defmodule Nectar.Admin.StateController do
  use Nectar.Web, :admin_controller

  alias Nectar.Country
  alias Nectar.State

  plug :scrub_params, "state" when action in [:create]
  plug :load_country when action in [:create]

  def create(conn, %{"state" => state_params}) do
    country = conn.assigns[:country]
    case Nectar.Command.State.insert_for_country(Repo, country, state_params) do
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
    state = Nectar.Query.State.get!(Repo, id)
    Nectar.Command.State.delete!(Repo, state)

    conn
    |> put_status(:no_content)
    |> json(nil)
  end

  defp load_country(conn, _params) do
    country_id = conn.params["country_id"]
    country = Nectar.Query.Country.get!(Repo, country_id)
    assign(conn, :country, country)
  end

end
