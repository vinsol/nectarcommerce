defmodule Nectar.Command.User do
  use Nectar.Command, model: Nectar.User

  def register_user(repo, attrs) do
    Nectar.User.registration_changeset(%Nectar.User{}, attrs)
    |> repo.insert
  end

  def register_admin(repo, attrs) do
    Nectar.User.admin_registration_changeset(%Nectar.User{}, attrs)
    |> repo.insert
  end

  def login(repo, login_params) do
    Nectar.User.login_changeset(%Nectar.User{}, login_params)
    |> attempt_login(repo)
  end

  defp attempt_login(%{valid?: false} = changeset, repo), do: {:error, changeset}
  defp attempt_login(%{valid?: true} = changeset, repo) do
    email = changeset.changes[:email]
    user  = Nectar.Query.User.get_by(repo, email: email)
    if user do
      verify_password(user, changeset)
    else
      errored_changeset = Ecto.Changeset.add_error(changeset, :user, "Invalid credentials")
      {:error, errored_changeset}
    end
  end

  defp verify_password(user, changeset) do
    case Comeonin.Bcrypt.checkpw(changeset.changes[:password], user.encrypted_password) do
      true  -> {:ok, user}
      false -> {:error, Ecto.Changeset.add_error(changeset, :user, "Invalid credentials")}
    end
  end
end
