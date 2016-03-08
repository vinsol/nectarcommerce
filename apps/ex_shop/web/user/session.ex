defmodule ExShop.Session do
  alias ExShop.User
  alias Ecto.Changeset

  def admin_login(changeset = %{params: %{"email" => email}}, repo) when (email == "" or email == nil) do
    changeset = changeset
      |> Changeset.add_error(:email, "can't be blank")

    {:error, changeset}
  end

  def admin_login(changeset = %{params: %{"password" => password}}, repo) when (password == "" or password == nil) do
    changeset = changeset
      |> Changeset.add_error(:password, "can't be blank")

    {:error, changeset}
  end

  def admin_login(changeset = %{params: %{"email" => email, "password" => password}}, repo) do
    user = repo.get_by(User, email: String.downcase(email), is_admin: true)
    case authenticate(changeset, user, password) do
      {:ok, user} -> {:ok, user}
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp authenticate(changeset, user, password) when user == nil do
    changeset = changeset
      |> Changeset.add_error(:email, "not found in records")
    {:error, changeset}
  end

  defp authenticate(changeset, user, password) do
    case Comeonin.Bcrypt.checkpw(password, user.encrypted_password) do
      true -> {:ok, user}
      false -> {:error, changeset |> Changeset.add_error(:password, "not matched with records")}
    end
  end
end
