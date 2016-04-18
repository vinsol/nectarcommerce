defmodule Nectar.User.Session do
  alias Nectar.User
  alias Ecto.Changeset

  def admin_login(changeset, repo) do
    login(changeset, repo, true)
  end

  def user_login(changeset, repo) do
    # TODO: Check whether is_admin scope should
    # be mandatory for user or can be just dropped
    login(changeset, repo, false)
  end

  def login(changeset = %{params: %{"email" => email}}, _repo, _is_admin) when (email == "" or is_nil(email)) do
    changeset = changeset
      |> Changeset.add_error(:email, "can't be blank")

    {:error, changeset}
  end
  def login(changeset = %{params: %{"password" => password}}, _repo, _is_admin) when (password == "" or is_nil(password)) do
    changeset = changeset
      |> Changeset.add_error(:password, "can't be blank")

    {:error, changeset}
  end
  def login(changeset = %{params: %{"email" => email, "password" => password}}, repo, is_admin) do
    user = repo.get_by(User, email: String.downcase(email), is_admin: is_admin)
    case authenticate(changeset, user, password) do
      {:ok, user} -> {:ok, user}
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp authenticate(changeset, user, _password) when user == nil do
    changeset = changeset
      |> Changeset.add_error(:email, "not found in records or check user/admin login")
    {:error, changeset}
  end

  defp authenticate(changeset, user, password) do
    case Comeonin.Bcrypt.checkpw(password, user.encrypted_password) do
      true -> {:ok, user}
      false -> {:error, changeset |> Changeset.add_error(:password, "not matched with records or check user/admin login")}
    end
  end
end
