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

    # virtual fields
    field :confirm, :boolean, virtual: true
    field :tax_confirm, :boolean, virtual: true
    field :same_as_billing, :boolean, virtual: true
    # use to hold invoices and payment methods
    field :applicable_shipping_methods, {:array, :map}, virtual: true
    field :applicable_payment_methods,  {:array, :map}, virtual: true

    # relationships
    has_many :line_items, Nectar.LineItem
    has_many :adjustments, Nectar.Adjustment
    has_one  :shipping, Nectar.Shipping
    has_many :variants, through: [:line_items, :variant]
    has_one  :payment, Nectar.Payment

    has_one  :order_billing_address, Nectar.OrderBillingAddress
    has_one  :billing_address, through: [:order_billing_address, :address]

    has_one  :order_shipping_address, Nectar.OrderShippingAddress
    has_one  :shipping_address, through: [:order_shipping_address, :address]

    belongs_to :user, Nectar.User

    extensions
    timestamps
  end

  @required_fields ~w(state)
  @optional_fields ~w(slug confirmation_status same_as_billing)

  @states ~w(cart address shipping tax payment confirmation)

  def states do
    @states
  end

  def confirmed?(%Order{state: "confirmation"}), do: true
  def confirmed?(%Order{state: _}), do: false

  def in_cart_state?(%Order{state: "cart"}), do: true
  def in_cart_state?(%Order{state: _}), do: false

  def cart_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(state), ~w())
  end

  def user_cart_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(state user_id), ~w())
  end

  def cart_update_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(), ~w())
    |> cast_assoc(:line_items, with: &Nectar.LineItem.direct_quantity_update_changeset/2)
  end

  def link_to_user_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(user_id), ~w())
    |> validate_order_not_confirmed
  end

  defp validate_order_not_confirmed(changeset) do
    if confirmed? changeset.model do
      add_error(changeset, :order, "Cannot update confirmed order")
    else
      changeset
    end
  end

  # cancelling all line items will automatically cancel the order.
  def cancel_order(model) do
    Repo.transaction(fn ->
      model
      |> Nectar.Repo.preload([:line_items])
      |> Map.get(:line_items)
      |> Enum.each(&(Nectar.LineItem.cancel_fullfillment(&1)))
    end)
  end

  def move_back_to_cart_state(order) do
    Nectar.Repo.transaction(fn ->
      order
      |> delete_payments
      |> delete_tax_adjustments
      |> delete_shippings
      |> delete_addresses
      |> cast(%{state: "cart"}, ~w(state), ~w())
      |> Nectar.Repo.update!
    end)
  end

  def move_back_to_address_state(order) do
    Nectar.Repo.transaction(fn ->
      order
      |> delete_payments
      |> delete_tax_adjustments
      |> delete_shippings
      |> cast(%{state: "address"}, ~w(state), ~w())
      |> Nectar.Repo.update!
    end)
  end

  def move_back_to_shipping_state(order) do
    Nectar.Repo.transaction(fn ->
      order
      |> delete_payments
      |> cast(%{state: "shipping"}, ~w(state), ~w())
      |> Nectar.Repo.update!
    end)
  end

  def move_back_to_tax_state(order) do
    Nectar.Repo.transaction(fn ->
      order
      |> delete_payments
      |> cast(%{state: "tax"}, ~w(state), ~w())
      |> Nectar.Repo.update!
    end)
  end

  def move_back_to_payment_state(order) do
    Nectar.Repo.transaction(fn ->
      order
      |> cast(%{state: "payment"}, ~w(state), ~w())
      |> Nectar.Repo.update!
    end)
  end

  alias Nectar.Repo

  defp delete_shippings(order) do
    shipping_ids = Repo.all(from o in assoc(order, :shipping), select: o.id)
    Repo.delete_all(from o in assoc(order, :adjustments), where: o.shipping_id in ^shipping_ids)
    Repo.delete_all(from o in assoc(order, :shipping))
    order
  end

  defp delete_tax_adjustments(order) do
    Repo.delete_all(from o in assoc(order, :adjustments), where: not(is_nil(o.tax_id)))
    order
  end

  defp delete_payments(order) do
    # will want to create a refund here
    Repo.delete_all(from o in assoc(order, :payment))
    order
  end

  defp delete_addresses(order) do
    # Caution, dangerous bug, since assoc will load with where order_id
    # both of these actions have same impact
    Repo.delete_all(from o in assoc(order, :order_billing_address))
    Repo.delete_all(from o in assoc(order, :order_shipping_address))
    order
  end


  def confirm_availability(order) do
    {sufficient_quantity_available, oos_items} =
      Nectar.LineItem
      |> Nectar.LineItem.in_order(order.model)
      |> Nectar.Repo.all
      |> Nectar.Repo.preload(:variant)
      |> Enum.reduce({true, []}, fn (ln_item, {status, out_of_stock}) ->
                                   {available, _} = Nectar.LineItem.sufficient_quantity_available?(ln_item)
                                   if available do
                                     {status, out_of_stock}
                                   else
                                     {false, [ln_item|out_of_stock]}
                                   end
                                 end)
    if sufficient_quantity_available do
      order
    else
      name_of_oos =
       oos_items
       |> Enum.reduce("", fn (item, acc) -> acc <> Nectar.Variant.display_name(item.variant) <> "," end)
      add_error(order, :line_items, "#{name_of_oos} are out of stock")
    end
  end

  # returns the appropriate changeset required based on the next state
  def transition_changeset(model, next_state, params \\ :empty) do
    case params do
      :empty -> apply(Nectar.Order, String.to_atom("#{next_state}_changeset"), [with_preloaded_assoc(model, next_state)])
        _    -> apply(Nectar.Order,
                      String.to_atom("#{next_state}_changeset"),
                      [with_preloaded_assoc(model, next_state), Dict.merge(%{"state" => next_state}, params)])
    end
  end

  def with_preloaded_assoc(model, "address") do
    Nectar.Repo.get!(Order, model.id)
    |> Nectar.Repo.preload([:order_shipping_address, :order_billing_address, :line_items, :shipping_address, :billing_address])
  end

  def with_preloaded_assoc(model, "shipping") do
    order = Nectar.Repo.get!(Order, model.id) |> Repo.preload([:shipping])
    %Order{order|applicable_shipping_methods: Nectar.ShippingCalculator.calculate_applicable_shippings(order)}
  end

  def with_preloaded_assoc(model, "tax") do
    Nectar.Repo.get!(Order, model.id)
    |> Nectar.Repo.preload([adjustments: [:tax, shipping: :shipping_method]])
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

  def settle_adjustments_and_product_payments(model) do
    adjustment_total = shipping_total(model) |> Decimal.add(tax_total(model))
    product_total = product_total(model)
    total = Decimal.add(adjustment_total, product_total)
    model
    |> cast(%{total: total, product_total: product_total,
              confirmation_status: can_be_fullfilled?(model)},
            ~w(confirmation_status total product_total), ~w())
    |> Repo.update!
  end

  # if none of the line items can be fullfilled cancel the order
  def can_be_fullfilled?(%Nectar.Order{} = order) do
    Nectar.Repo.all(from ln in assoc(order, :line_items), select: ln.fullfilled)
    |> Enum.any?
  end

  def cart_empty?(%Nectar.Order{} = order) do
    Nectar.Repo.one(from ln in assoc(order, :line_items), select: count(ln.id)) == 0
  end

  def shipping_total(model) do
    Nectar.Repo.one(
      from shipping_adj in assoc(model, :adjustments),
      where: not is_nil(shipping_adj.shipping_id),
      select: sum(shipping_adj.amount)
    ) || Decimal.new("0")
  end

  def tax_total(model) do
    Nectar.Repo.one(
      from tax_adj in assoc(model, :adjustments),
      where: not is_nil(tax_adj.tax_id),
      select: sum(tax_adj.amount)
    ) || Decimal.new("0")
  end

  def product_total(model) do
    Nectar.Repo.one(
      from line_item in assoc(model, :line_items),
      where: line_item.fullfilled == true,
      select: sum(line_item.total)
    ) || Decimal.new("0")
  end

  def acquire_variant_stock(model) do
    Enum.each(model.line_items, &Nectar.LineItem.acquire_stock_from_variant/1)
    model
  end

  def restock_unfullfilled_line_items(model) do
    Enum.each(model.line_items, &Nectar.LineItem.restock_variant/1)
    model
  end

  def address_changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> ensure_cart_is_not_empty
    |> cast_assoc(:order_billing_address, required: true)
    |> duplicate_params_if_same_as_billing
    |> cast_assoc(:order_shipping_address, required: true)
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
  def shipping_changeset(model, params \\ :empty) do
    model
    |> cast(shipping_params(model, params), @required_fields, @optional_fields)
    |> cast_assoc(:shipping, required: true, with: &Nectar.Shipping.applicable_shipping_changeset/2)
  end

  defp shipping_params(_order, %{"shipping" => %{"shipping_method_id" => ""}} = params), do: params
  defp shipping_params(order, %{"shipping" => shipping_params} = params) do
    shipping_method = Nectar.Repo.get(Nectar.ShippingMethod, shipping_params["shipping_method_id"])
    %{params | "shipping" => %{shipping_method_id: shipping_method.id,
                              adjustment: %{amount: Nectar.ShippingCalculator.shipping_cost(shipping_method, order), order_id: order.id}}}
  end
  defp shipping_params(_order, params), do: params

  # no changes to be made with tax
  def tax_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(tax_confirm state), @optional_fields)
    |> validate_tax_confirmed
  end

  # select payment method from list of payments
  def payment_changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> cast_assoc(:payment, required: true, with: &Nectar.Payment.applicable_payment_changeset/2)
  end

  # Check availability and othe stuff here
  def confirmation_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(confirm state), ~w())
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

  defp ensure_cart_is_not_empty(model) do
    line_items = get_field(model, :line_items)
    case line_items do
      []  -> add_error(model, :line_items, "Please add some item to your cart to proceed")
      _   -> model
    end
  end

  def current_order(%Nectar.User{} = user) do
    Repo.one(from order in all_abandoned_orders_for(user),
             order_by: [desc: order.updated_at],
             limit: 1)
  end

  def all_abandoned_orders_for(%Nectar.User{} = user) do
    (from order in all_orders_for(user),
     where: not(order.state == "confirmation"))
  end

  def all_orders_for(%Nectar.User{id: id}) do
    (from o in Nectar.Order, where: o.user_id == ^id)
  end

end
