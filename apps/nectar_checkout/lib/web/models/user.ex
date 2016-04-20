defmodule Nectar.UserForCheckout do

  use NectarCore.Web, :model

  schema "users" do
    field :name, :string
    field :email, :string
    field :encrypted_password, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :is_admin, :boolean

    has_many :orders, Nectar.Order, foreign_key: :user_id
    has_many :user_addresses, Nectar.UserAddress
    has_many :addresses, through: [:user_addresses, :address]

    timestamps
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(), ~w())
  end

  @doc """
  Refer Registration changeset
  """
  def create_changeset(model, params \\ :empty), do: changeset(model, params) |> add_error(:email, "Refer Registration changeset")

  @doc """
  Updates a user changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def update_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(email), ~w(name password password_confirmation is_admin))
    |> changeset_helper
  end

  def changeset_helper(changeset) do
    changeset
    |> validate_confirmation(:password, message: "password does not match")
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 5)
    |> unique_constraint(:email)
    |> set_hashed_password
  end

  # Changing pattern match to valid?: instead of errors:
  # would fail for more than one error also :(
  # Passing no params to changeset, results in valid? to be false
  # should not be a problem here but good to know as could lead to some edge case :P
  # Intent is to not perform hashing if changeset is invalid
  defp set_hashed_password(changeset = %{valid?: false}), do: changeset
  defp set_hashed_password(changeset = %{params: %{"password" => password}}) when password != "" and not(is_nil(password)) do
    changeset
    |> put_change(:encrypted_password, Comeonin.Bcrypt.hashpwsalt(password))
  end
  # No Error added as create_changeset makes password mandatory in cast
  # but update_changeset can ignore
  defp set_hashed_password(changeset), do: changeset
end
