defmodule ExShop.Payment do
  use ExShop.Web, :model

  schema "payments" do
    belongs_to :order, ExShop.Order
    belongs_to :payment_method, ExShop.PaymentMethod
    field :selected, :boolean, default: false

    timestamps
  end

  @required_fields ~w(payment_method_id)
  @optional_fields ~w(selected)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  # TODO: can we add errors while payment authorisation here ??
end
