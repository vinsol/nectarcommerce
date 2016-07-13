defmodule Nectar.UserTest.Shared do

  defmacro encryped_password_tests do
    quote location: :keep do
      @tag valid_changeset: true
      test "generates encrypted_password", %{changeset: changeset} do
        assert changeset.valid?
        assert Map.has_key? changeset.changes, :encrypted_password
      end

      @tag valid_changeset: false
      test "does not generate encrypted_password if changeset not valid", %{changeset: changeset} do
        refute changeset.valid?
        refute Map.has_key? changeset.changes, :encrypted_password
      end
    end
  end

  defmacro password_confirmation_tests do
    quote location: :keep do
      @tag valid_changeset: false
      test "password confirmation", %{changeset: changeset} do
        refute changeset.valid?
        assert errors_on(changeset)[:password_confirmation] == "password does not match"
      end
    end
  end

  defmacro user_changeset_tests do
    quote location: :keep do
      @tag valid_changeset: true
      test "sanity", %{changeset: changeset} do
        changeset.valid?
      end

      @tag valid_changeset: false
      test "email can't be blank", %{changeset: changeset} do
        refute changeset.valid?
        assert errors_on(changeset)[:email] == "can't be blank"
      end

      @tag valid_changeset: false
      test "password length",  %{changeset: changeset} do
        refute changeset.valid?
        assert errors_on(changeset)[:password] == "should be at least 5 character(s)"
      end
    end
  end
end

defmodule Nectar.UserTest do
  use Nectar.ModelCase, async: true
  require __MODULE__.Shared
  alias __MODULE__.Shared
  alias Nectar.User
  alias Nectar.TestSetup

  describe "fields" do
    has_fields User, ~w(id name email encrypted_password is_admin)a ++ timestamps
  end

  describe "associations" do
    has_associations User, ~w(orders user_addresses addresses)a
    has_many? User, :orders,         via: Nectar.Order
    has_many? User, :user_addresses, via: Nectar.UserAddress
    has_many? User, :addresses,      through: [:user_addresses, :address]
  end

  describe "changeset" do
    setup context do
      changeset = if context[:valid_changeset] do
        User.changeset(TestSetup.User.dummy_user_struct, TestSetup.User.valid_attrs)
      else
        User.changeset(TestSetup.User.dummy_user_struct,
          Map.merge(TestSetup.User.invalid_attrs, %{password: "abc", password_confirmation: "not abc"}))
      end
      {:ok, %{changeset: changeset}}
    end

    Shared.user_changeset_tests
    Shared.encryped_password_tests
    Shared.password_confirmation_tests
  end

  describe "registration_changeset" do
    setup context do
      changeset = if context[:valid_changeset] do
        User.registration_changeset(%User{}, TestSetup.User.valid_attrs)
      else
        User.registration_changeset(%User{},
          Map.merge(TestSetup.User.invalid_attrs,
            %{password: "abc", password_confirmation: "not abc"}))
      end
      {:ok, %{changeset: changeset}}
    end

    Shared.user_changeset_tests
    Shared.encryped_password_tests
    Shared.password_confirmation_tests
  end

  describe "admin_registration_changeset" do
    setup context do
      changeset = if context[:valid_changeset] do
        User.admin_registration_changeset(%User{}, TestSetup.User.valid_attrs)
      else
        User.admin_registration_changeset(%User{},
          Map.merge(TestSetup.User.invalid_attrs,
            %{password: "abc", password_confirmation: "not abc"}))
      end
      {:ok, %{changeset: changeset}}
    end

    Shared.user_changeset_tests
    Shared.encryped_password_tests
    Shared.password_confirmation_tests

    @tag valid_changeset: true
    test "adds is_admin = true change", %{changeset: changeset} do
      assert changeset.changes[:is_admin]
    end
  end


  describe "login_changeset" do
    setup context do
      changeset = if context[:valid_changeset] do
        User.login_changeset(%User{}, TestSetup.User.valid_attrs)
      else
        User.login_changeset(%User{}, Map.merge(TestSetup.User.invalid_attrs, %{password: "abc"}))
      end
      {:ok, %{changeset: changeset}}
    end

    Shared.user_changeset_tests

    test "password can't be blank" do
      changeset = User.login_changeset(%User{}, TestSetup.User.invalid_attrs)
      refute changeset.valid?
      assert errors_on(changeset)[:password] == "can't be blank"
    end
  end

  describe "is_admin" do
    test "when admin returns true" do
      user = %User{is_admin: true}
      assert User.admin?(user)
    end

    test "when not admin returns false" do
      user = %User{is_admin: false}
      refute User.admin?(user)
    end
  end

end
