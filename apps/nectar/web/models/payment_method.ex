defmodule Nectar.PaymentMethod do

  use Nectar.Web, :model

  schema "payment_methods" do
    field :name, :string
    has_many :payments, Nectar.Payment
    field :enabled, :boolean, default: false
    extensions
  end

  @required_fields ~w(name)a
  @optional_fields ~w(enabled)a

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  def enabled_payment_methods do
    from pay in Nectar.PaymentMethod,
    where: pay.enabled
  end

  def enable(payment_method_ids) do
    from payment in Nectar.PaymentMethod,
    where: payment.id in ^payment_method_ids,
    update: [set: [enabled: true]]
  end

  def disable_other_than(payment_method_ids) do
    from payment in Nectar.PaymentMethod,
    where: not payment.id in ^payment_method_ids,
    update: [set: [enabled: false]]
  end
end
