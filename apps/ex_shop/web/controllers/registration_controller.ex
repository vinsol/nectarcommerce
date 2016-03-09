defmodule ExShop.RegistrationController do
  use ExShop.Web, :controller

  alias ExShop.User.Registration
  alias ExShop.User

  plug :scrub_params, "registration" when action in [:create, :update]

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"registration" => registration_params}) do
    changeset = Registration.user_changeset(%User{}, registration_params)

    case Repo.insert(changeset) do
      {:ok, _registration} ->
        conn
        |> put_flash(:info, "User registered successfully.")
        |> redirect(to: page_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
