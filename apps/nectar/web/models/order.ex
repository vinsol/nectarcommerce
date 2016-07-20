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

  def check_if_variants_in_stock(%Ecto.Changeset{model: order}) do
    check_if_variants_in_stock(order)
  end

  def check_if_variants_in_stock(order) when is_binary(order) do
    check_if_variants_in_stock(String.to_integer(order))
  end

  def check_if_variants_in_stock(order) when is_number(order) do
    order = Repo.get!(Order, order) |> Repo.preload([line_items: :variant])
    check_if_variants_in_stock(order)
  end

  def check_if_variants_in_stock(%Order{} = order) do
    reduction_function =
      fn (ln_item, {status, out_of_stock}) ->
        {available, _} = Nectar.LineItem.sufficient_quantity_available?(ln_item)
        if available do
          {status, out_of_stock}
        else
          {false, [ln_item|out_of_stock]}
        end
    end

    Nectar.LineItem
    |> Nectar.LineItem.in_order(order)
    |> Nectar.Repo.all
    |> Nectar.Repo.preload(:variant)
    |> Enum.reduce({true, []}, reduction_function)
  end

  # returns the appropriate changeset required based on the next state
  def transition_changeset(model, next_state, params \\ %{}) do
    case params do
      %{} = opt when opt == %{} ->
        apply(Nectar.Order, String.to_atom("#{next_state}_changeset"), [with_preloaded_assoc(model, next_state)])

      _ -> apply(Nectar.Order,
                 String.to_atom("#{next_state}_changeset"),
                 [with_preloaded_assoc(model, next_state),
                  Dict.merge(%{"state" => next_state}, params)])
    end
  end

  def with_preloaded_assoc(model, "address") do
    Nectar.Repo.get!(Order, model.id)
    |> Nectar.Repo.preload([:order_shipping_address, :order_billing_address, :line_items, :shipping_address, :billing_address])
  end

  def with_preloaded_assoc(model, "shipping") do
    order = Nectar.Repo.get!(Order, model.id) |> Repo.preload([shipment_units: [shipment: [:shipping_method, :adjustment], line_items: [variant: :product]]])
  end

  def with_preloaded_assoc(model, "tax") do
    Nectar.Repo.get!(Order, model.id)
    |> Nectar.Repo.preload([adjustments: [:tax, shipment: :shipping_method]])
  end

  def with_preloaded_assoc(model, "payment") do
    order = Nectar.Repo.get!(Order, model.id)
    |> Nectar.Repo.preload([:payment])
    %Order{order|applicable_payment_methods: Nectar.Invoice.generate_applicable_payment_invoices(order)}
  end

  def with_preloaded_assoc(model, "confirmation") do
    Nectar.Repo.get!(Order, model.id)
    |> Nectar.Repo.preload([line_items: :variant])
  end

  def with_preloaded_assoc(model, _) do
    model
  end

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
      billing_address_id = get_field(billing_address_changes, :address_id)
      updated_params = Map.put(changeset.params, "order_shipping_address", %{"address_id" => billing_address_id})
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
    |> cast_assoc(:shipment_units, required: true, with: &Nectar.ShipmentUnit.create_shipment_changeset/2)
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

  def transaction_id_changeset(model, transaction_id) do
    payment_changes = put_change(model.changes[:payment], :transaction_id, transaction_id)
    %Ecto.Changeset{model | changes: %{model.changes | payment: payment_changes}}
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
