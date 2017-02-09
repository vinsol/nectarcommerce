defmodule Nectar.User do
  use Nectar.Web, :model

  schema "users" do
    field :name, :string
    field :email, :string
    field :encrypted_password, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :is_admin, :boolean, default: false

    has_many :orders, Nectar.Order
    has_many :user_addresses, Nectar.UserAddress
    has_many :addresses, through: [:user_addresses, :address]

    extensions()
    timestamps()
  end

  def admin?(%__MODULE__{is_admin: is_admin}), do: is_admin

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, ~w(email name password password_confirmation is_admin))
    |> shared_validations
    |> password_confirm_and_set_hashed
  end

  def login_changeset(model, params \\ %{}) do
    model
    |> cast(params, ~w(email password))
    |> validate_required(~w(email password)a)
    |> shared_validations
  end

  def registration_changeset(model, params \\ %{}) do
    model
    |> cast(params, ~w(email password password_confirmation))
    |> validate_required(~w(email password password_confirmation)a)
    |> shared_validations
    |> password_confirm_and_set_hashed
  end

  defp password_confirm_and_set_hashed(changeset) do
    changeset
    |> validate_confirmation(:password, message: "password does not match")
    |> set_hashed_password
  end

  def admin_registration_changeset(model, params \\ %{}) do
    registration_changeset(model, params)
    |> put_change(:is_admin, true)
  end

  defp shared_validations(changeset) do
    changeset
    |> validate_required(~w(email)a)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 5)
    |> unique_constraint(:email)
  end

  # Do not hash if changeset is invalid
  defp set_hashed_password(changeset = %{valid?: false}), do: changeset
  defp set_hashed_password(changeset) do
    password = get_change(changeset, :password)
    if password do
      changeset
      |> put_change(:encrypted_password, Comeonin.Bcrypt.hashpwsalt(password))
    else
      changeset
    end
  end
end
