defmodule ExShop.Session do
  alias ExShop.User

  def admin_login(params, repo) do
    user = repo.get_by(User, email: String.downcase(params["email"]), is_admin: true)
    case authenticate(user, params["password"]) do
      true -> {:ok, user}
      _    -> {:error, nil}
    end
  end

  defp authenticate(user, password) do
    case user do
      nil -> false
      _   -> Comeonin.Bcrypt.checkpw(password, user.encrypted_password)
    end
  end
end
