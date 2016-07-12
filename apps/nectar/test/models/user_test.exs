defmodule Nectar.UserTest do
  use Nectar.ModelCase, async: true
  alias Nectar.User

  describe "fields" do
    has_fields User, ~w(id name email encrypted_password is_admin)a ++ timestamps
  end

  describe "associations" do
    has_associations User, ~w(orders user_addresses addresses)a
  end
end
