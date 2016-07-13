defmodule Nectar.TestSetup.User do
  def valid_attrs, do: %{email: "mail@example.com", password: "password", password_confirmation: "password"}
  def invalid_attrs, do: %{}
  def dummy_user_struct, do: %Nectar.User{}

  def create_user, do: Nectar.Command.User.register_user(Nectar.Repo, valid_attrs)
  def create_admin, do: Nectar.Command.User.register_admin(Nectar.Repo, valid_attrs)

end
