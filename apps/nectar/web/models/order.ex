defmodule Nectar.Order do
  use Nectar.Web, :model

  alias __MODULE__

  schema "orders" do
    # concrete fields
    field :slug, :string
    field :state, :string, default: "cart"
    field :total, :decimal, default: Decimal.new("0")
    field :confirmation_status, :boolean, default: true
    field :product_total, :decimal, default: Decimal.new("0")
    field :order_state, :string, default: "confirmed"

    # virtual fields
    field :confirm, :boolean, virtual: true
    field :tax_confirm, :boolean, virtual: true
    field :same_as_billing, :boolean, virtual: true
    # use to hold invoices and payment methods
    field :applicable_shipping_methods, {:array, :map}, virtual: true
    field :applicable_payment_methods,  {:array, :map}, virtual: true

    # relationships
    has_many :line_items, Nectar.LineItem
    has_many :shipment_units, Nectar.ShipmentUnit # added for convenience
    has_many :shipments, through: [:shipment_units, :shipment]
    has_many :adjustments, Nectar.Adjustment
    has_one  :shipping, Nectar.Shipping
    has_many :variants, through: [:line_items, :variant]
    has_one  :payment, Nectar.Payment

    has_one  :order_billing_address, Nectar.OrderBillingAddress
    has_one  :billing_address, through: [:order_billing_address, :address]

    has_one  :order_shipping_address, Nectar.OrderShippingAddress
    has_one  :shipping_address, through: [:order_shipping_address, :address]

    belongs_to :user, Nectar.User

    timestamps
    extensions
  end

  @required_fields ~w(state)a
  @optional_fields ~w(slug confirmation_status same_as_billing)a

  @states          ~w(cart address shipping tax payment confirmation)
  @order_states    ~w(confirmed partially_fullfilled fullfilled)

  def states do
    @states
  end

  def order_states do
    @order_states
  end

  def confirmed?(%Order{state: "confirmation"}), do: true
  def confirmed?(%Order{state: _}), do: false

  def in_cart_state?(%Order{state: "cart"}), do: true
  def in_cart_state?(%Order{state: _}), do: false

  @required_fields ~w(state)a
  @optional_fields ~w(same_as_billing)a
  def address_changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> cast_assoc(:order_billing_address, required: true)
    |> duplicate_params_if_same_as_billing
    |> cast_assoc(:order_shipping_address, required: true)
  end

  def payment_changeset(model, params \\ %{}) do
    model
    |> cast(payment_params(model, params), @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> cast_assoc(:payment, required: true, with: &Nectar.Payment.applicable_payment_changeset/2)
  end

  @required_fields ~w(state)a
  @optional_fields ~w()a
  def cart_changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  @required_fields ~w(state user_id)a
  @optional_fields ~w()a
  def user_cart_changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  @required_fields ~w()a
  @optional_fields ~w()a
  def cart_update_changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> cast_assoc(:line_items, with: &Nectar.LineItem.direct_quantity_update_changeset/2)
  end

  @required_fields ~w(user_id)a
  @optional_fields ~w()a
  def link_to_user_changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_order_not_confirmed
  end

  defp validate_order_not_confirmed(changeset) do
    if confirmed? changeset.data do
      add_error(changeset, :order, "Cannot update confirmed order")
    else
      changeset
    end
  end

  @required_fields ~w(state)a
  @optional_fields ~w()a
  def state_changeset(order, params) do
    order
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end


  @required_fields ~w(total product_total confirmation_status)a
  @optional_fields ~w()a
  def settlement_changeset(order, params) do
    order
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  def acquire_variant_stock(model) do
    Enum.each(model.line_items, &Nectar.LineItem.acquire_stock_from_variant/1)
    model
  end

  def restock_unfullfilled_line_items(model) do
    Enum.each(model.line_items, &Nectar.LineItem.restock_variant/1)
    model
  end

  defp duplicate_params_if_same_as_billing(changeset) do
    same_as_billing = get_field(changeset, :same_as_billing)
    billing_address_changes = changeset.changes[:order_billing_address]
    if same_as_billing && billing_address_changes do
      updated_params = Map.put(changeset.params, "order_shipping_address", changeset.params["order_billing_address"])
      %Ecto.Changeset{changeset|params: updated_params}
    else
      changeset
    end
  end

  # use this to set shipping
  @required_fields ~w(state)a
  @optional_fields ~w()a
  def shipping_changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> ensure_presence_of_shipment_units
    |> cast_assoc(:shipment_units, required: true, with: &Nectar.ShipmentUnit.create_shipment_changeset/2)
  end

  defp ensure_presence_of_shipment_units(%Ecto.Changeset{params: params} = changeset) do
    unless params["shipment_units"] do
      add_error(changeset, :shipment_units, "are required")
    else
      changeset
    end
  end

  defp ensure_presence_of_shipment_units(%Ecto.Changeset{} = changeset) do
    add_error(changeset, :shipment_units, "are required")
  end

  # no changes to be made with tax
  @required_fields ~w(tax_confirm state)a
  @optional_fields ~w()a
  def tax_changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_tax_confirmed
  end

  def transaction_id_changeset(model, params) do
    model
    |> cast(params, ~w()a)
    |> cast_assoc(:payment, with: &Nectar.Payment.transaction_id_changeset/2)
  end

  def payment_params(order, %{"payment" => %{"payment_method_id" => ""}} = params), do: params
  def payment_params(order, %{"payment" => %{"payment_method_id" => payment_method_id}} = params) do
    %{params|"payment" => %{"payment_method_id" => payment_method_id, "amount" => order.total}}
  end
  def payment_params(order, params), do: params

  # Check availability and othe stuff here
  @required_fields ~w(confirm state)a
  @optional_fields ~w()
  def confirmation_changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_order_confirmed
  end

  defp validate_order_confirmed(model) do
    confirmed = get_field(model, :confirm)
    if confirmed do
      model
    else
      add_error(model, :confirm, "Please confirm to finalise the order")
    end
  end

  defp validate_tax_confirmed(model) do
    confirmed = get_field(model, :tax_confirm)
    if confirmed do
      model
    else
      add_error(model, :tax_confirm, "Please confirm to proceed")
    end
  end

end
