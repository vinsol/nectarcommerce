defmodule ExShop.Address do
  use ExShop.Web, :model

  schema "addresses" do
    field :address_line_1, :string
    field :address_line_2, :string
    field :address_type, ExShop.AddressType, default: ExShop.AddressType.get_address_type!("shipping")

    belongs_to :state, ExShop.State
    belongs_to :country, ExShop.Country
    belongs_to :order, ExShop.Order


    timestamps
  end

  @required_fields ~w(address_line_1 address_line_2 country_id state_id)
  @optional_fields ~w(address_type)


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

  @billing_address_type ExShop.AddressType.get_address_type!("billing")
  def billing_address_changeset(model, params \\ :empty) do
    changeset = changeset(model, params)
    put_change(changeset, :address_type, @billing_address_type)
  end
end
