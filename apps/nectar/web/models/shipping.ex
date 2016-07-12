defmodule Nectar.Shipping do
  use Nectar.Web, :model

  schema "shippings" do
    belongs_to :order, Nectar.Order
    belongs_to :shipping_method, Nectar.ShippingMethod
    has_one :adjustment, Nectar.Adjustment
    field :shipping_state, :string, default: "shipment_created"

    timestamps
    extensions
  end

  @shipping_states ~w(shipment_created pending shipped received return_initiated picked_up return_received)

  @required_fields ~w(shipping_method_id)a
  @optional_fields ~w()a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  def applicable_shipping_changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> cast_assoc(:adjustment)
    |> foreign_key_constraint(:shipping_method_id)
  end

  def for_order(%Nectar.Order{id: order_id}) do
    from p in Nectar.Shipping,
    where: p.order_id == ^order_id
  end

end
