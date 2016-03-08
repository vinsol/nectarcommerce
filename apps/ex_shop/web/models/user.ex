defmodule ExShop.User do
  use ExShop.Web, :model

  schema "users" do
    field :name, :string
    field :email, :string
    field :encrypted_password, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :is_admin, :boolean

    timestamps
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(), ~w(email password))
  end

  @doc """
  Creates a register form changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def register_admin_form_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(name email password is_admin), ~w())
  end

  @doc """
  Creates a create user changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def create_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(name email password), ~w())
    |> validate_confirmation(:password, message: "password does not match")
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 5)
    |> unique_constraint(:email)
  end
end
