defmodule ExShop.Registration do
  alias ExShop.User
  alias Ecto.Changeset

  import ExShop.User, only: [changeset_helper: 1]

  def admin_changeset(changeset, params) do
    User.changeset(changeset, params)
    |> Changeset.cast(params, ~w(email password), ~w(name password_confirmation is_admin))
    |> changeset_helper
  end

  def user_changeset(changeset, params) do
    User.changeset(changeset, params)
    |> Changeset.cast(params, ~w(email password), ~w(name password_confirmation))
    |> changeset_helper
    |> Changeset.put_change(:is_admin, false)
  end
end
