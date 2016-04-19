defmodule Nectar.Address do
  use NectarCore.Web, :model

  schema "addresses" do
    field :address_line_1, :string
    field :address_line_2, :string

    belongs_to :state, Nectar.State
    belongs_to :country, Nectar.Country

    has_one :user_address, Nectar.UserAddress
    has_one :user, through: [:user_address, :user]

    has_many :order_billing_addresses, Nectar.OrderBillingAddress
    has_many :billing_orders, through: [:order_billing_addresses, :order]

    has_many :order_shipping_addresses, Nectar.OrderShippingAddress
    has_many :shipping_order, through: [:order_shipping_addresses, :order]

    timestamps
  end

  @required_fields ~w(address_line_1 address_line_2 country_id state_id)
  @optional_fields ~w()


  # currently called by order's build assoc
  # ensure all other keys are set
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:address_line_1, min: 10)
    |> validate_length(:address_line_2, min: 10)
    |> foreign_key_constraint(:state_id)
    |> foreign_key_constraint(:country_id)
  end

  def registered_user_changeset(model, params \\ :empty) do
    changeset(model, params)
    |> cast_assoc(:user_address, required: true)
  end

end
