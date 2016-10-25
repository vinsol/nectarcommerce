defmodule Nectar.ShippingMethod do
  use Nectar.Web, :model

  schema "shipping_methods" do
    field :name
    field :enabled, :boolean, default: false

    has_many :shippings, Nectar.Shipping
    field :shipping_cost, :decimal, virtual: true, default: Decimal.new("0")

    timestamps
    extensions
  end

  @required_fields ~w(name)a
  @optional_fields ~w(enabled)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

end
