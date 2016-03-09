defmodule ExShop.UserAddress do
  use ExShop.Web, :model

  schema "user_addresses" do
    belongs_to :user, ExShop.User
    belongs_to :address, ExShop.Address
    timestamps
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(), ~w(user_id address_id))
  end

end
