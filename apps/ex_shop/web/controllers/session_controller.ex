defmodule ExShop.SessionController do
  use ExShop.Web, :controller
  alias ExShop.User
  alias ExShop.Repo
  alias ExShop.User.Session

  plug :scrub_params, "user" when action in [:create]

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)
    case Session.user_login(changeset, Repo) do
      {:ok, user} ->
        IO.inspect user
        conn
        |> Guardian.Plug.sign_in(user)
        |> put_flash(:info, "Signed In Succesfully")
        |> redirect(to: page_path(conn, :index))
      {:error, changeset} ->
        conn
        |> render("new.html", changeset: changeset)
    end
  end

  def logout(conn, _params) do
    case Guardian.Plug.current_resource(conn) do
      nil ->
        conn
        |> put_flash(:info, "Not logged in")
        |> redirect(to: session_path(conn, :new))
      _ ->
        conn
        # This clears the whole session.
        # We could use sign_out(:default) to just revoke this token
        # but I prefer to clear out the session. This means that because we
        # use tokens in two locations - :default and :admin - we need to load it (see above)
        |> Guardian.Plug.sign_out
        |> put_flash(:info, "Signed out")
        |> redirect(to: session_path(conn, :new))
    end
  end
end
