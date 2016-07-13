defmodule Nectar.Command.UserTest do
  use Nectar.ModelCase
  alias Nectar.Command
  alias Nectar.TestSetup

  describe "login" do
    setup do
      {:ok, user} = TestSetup.User.create_user
      {:ok, %{user: user}}
    end

    test "with valid credentials", %{user: user} do
      {status, logged_in_user} =
        Command.User.login(Nectar.Repo, %{email: user.email, password: "password"})
      assert status == :ok
      assert logged_in_user.id == user.id
    end

    test "with no credentials" do
      {status, logged_in_user} =
        Command.User.login(Nectar.Repo, %{})
      assert status == :error
      assert errors_on(logged_in_user) == [email: "can't be blank", password: "can't be blank"]
    end

    test "with incorrect password", %{user: user} do
      {status, logged_in_user} =
        Command.User.login(Nectar.Repo, %{email: user.email, password: "passwor"})
      assert status == :error
      assert errors_on(logged_in_user) == [user: "Invalid credentials"]
    end

    test "with incorrect email", %{user: user} do
      {status, logged_in_user} =
        Command.User.login(Nectar.Repo, %{email: user.email <> "abc", password: "password"})
      assert status == :error
      assert errors_on(logged_in_user) == [user: "Invalid credentials"]
    end
  end

  describe "register_user" do
    test "with valid attributes" do
      {status, user} = Command.User.register_user(Nectar.Repo, Nectar.TestSetup.User.valid_attrs)
      assert status == :ok
      assert user.id
      refute user.is_admin
    end

    test "with invalid attributes" do
      {status, _user} = Command.User.register_user(Nectar.Repo, Nectar.TestSetup.User.invalid_attrs)
      refute status == :ok
    end
  end

  describe "register_admin" do
    test "with valid attributes" do
      {status, user} = Command.User.register_admin(Nectar.Repo, Nectar.TestSetup.User.valid_attrs)
      assert status == :ok
      assert user.id
      assert user.is_admin
    end

    test "with invalid attributes" do
      {status, _user} = Command.User.register_admin(Nectar.Repo, Nectar.TestSetup.User.invalid_attrs)
      refute status == :ok
    end
  end

end
