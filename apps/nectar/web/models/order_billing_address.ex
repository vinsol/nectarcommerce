defmodule Nectar.OrderBillingAddress do
  use Nectar.Web, :model

  schema "order_billing_addresses" do
    belongs_to :order, Nectar.Order
    belongs_to :address, Nectar.Address
    timestamps
    extensions
  end

  @required_fields ~w()
  @optional_fields  ~w(order_id)
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> cast_assoc(:address, required: true)
  end
end
