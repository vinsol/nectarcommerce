defmodule ExShop.Registration do
  alias ExShop.User
  alias Ecto.Changeset

  def changeset(changeset, params) do
    User.changeset(changeset, params)
    |> Changeset.cast(params, ~w(email password), ~w())
    |> Changeset.validate_confirmation(:password, message: "password does not match")
    |> Changeset.validate_format(:email, ~r/@/)
    |> Changeset.validate_length(:password, min: 5)
    |> Changeset.unique_constraint(:email)
    |> changeset_helper
  end

  defp changeset_helper(changeset) do
    changeset
    |> set_hashed_password
  end

  def set_hashed_password(changeset = %{errors: [_]}), do: changeset
  def set_hashed_password(changeset = %{params: %{"password" => password}}) when password != "" and password != nil do
    hashed_password = Comeonin.Bcrypt.hashpwsalt(password)

    changeset
    |> Changeset.put_change(:hashed_password, hashed_password)
  end
  def set_hashed_password(changeset) do
    changeset
    |> Changeset.add_error(:password, "can't be blank")
  end
end
