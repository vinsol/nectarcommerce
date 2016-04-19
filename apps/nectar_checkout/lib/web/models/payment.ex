defmodule Nectar.Payment do
  use NectarCore.Web, :model

  schema "payments" do
    belongs_to :order, Nectar.Order
    belongs_to :payment_method, Nectar.PaymentMethod

    timestamps
  end

  @required_fields ~w(payment_method_id)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end


  # TODO: can we add errors while payment authorisation here ??
  def applicable_payment_changeset(model, params) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def for_order(%Nectar.Order{id: order_id}) do
    from p in Nectar.Payment,
    where: p.order_id == ^order_id
  end

end
