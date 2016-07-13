defmodule Nectar.SessionController do
  use Nectar.Web, :controller
  alias Nectar.User
  alias Nectar.Repo
  alias Nectar.User.Session

  plug :scrub_params, "user" when action in [:create]

  def new(conn, _params) do
    changeset = User.login_changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    case Nectar.Command.User.login(Repo, user_params) do
      {:ok, user} ->
        conn
        |> Guardian.Plug.sign_in(user)
        |> put_flash(:info, "Signed In Succesfully")
        |> redirect(to: next_page_after_login(conn))
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

  defp next_page_after_login(conn) do
    next_page = get_session(conn, :next_page)
    if next_page do
      # remove it since it is not needed anymore.
      delete_session(conn, :next_page)
      next_page
    else
      home_path(conn, :index)
    end
  end
end
