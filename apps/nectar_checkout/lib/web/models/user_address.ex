defmodule Nectar.UserAddress do
  use Nectar.Web, :model

  schema "user_addresses" do
    belongs_to :user, Nectar.User
    belongs_to :address, Nectar.Address
    timestamps
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(), ~w(user_id address_id))
  end

end
