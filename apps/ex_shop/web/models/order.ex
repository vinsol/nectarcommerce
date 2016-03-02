defmodule ExShop.Order do
  use ExShop.Web, :model

  alias __MODULE__

  schema "orders" do
    field :slug, :string
    field :state, :string, default: "cart"
    field :confirm, :boolean, virtual: true
    field :total, :decimal
    field :tax_confirm, :boolean, virtual: true

    has_many :line_items, ExShop.LineItem
    has_many :adjustments, ExShop.Adjustment
    has_many :shippings, ExShop.Shipping
    has_many :variants, through: [:line_items, :variant]
    has_many :payments, ExShop.Payment

    has_one  :billing_address, ExShop.Address
    has_one  :shipping_address, ExShop.Address

    timestamps
  end

  @required_fields ~w(state)
  @optional_fields ~w(slug total)

  @states ~w(cart address shipping tax payment confirmation)

  def confirmed?(%Order{state: "confirmation"}), do: true
  def confirmed?(%Order{state: _}), do: false

  def cart_changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def confirm_availability(order) do
    {sufficient_quantity_available, oos_items} =
      ExShop.LineItem
      |> ExShop.LineItem.in_order(order.model)
      |> ExShop.Repo.all
      |> ExShop.Repo.preload(:variant)
      |> Enum.reduce({true, []}, fn (ln_item, {status, out_of_stock}) ->
                                   {available, _} = ExShop.LineItem.sufficient_quantity_available?(ln_item)
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
       |> Enum.reduce("", fn (item, acc) -> acc <> ExShop.Variant.display_name(item.variant) <> "," end)
      add_error(order, :line_items, "#{name_of_oos} are out of stock")
    end
  end

  # returns the appropriate changeset required based on the next state
  def transition_changeset(model, next_state, params \\ :empty) do
    case params do
      :empty -> apply(ExShop.Order, String.to_atom("#{next_state}_changeset"), [with_preloaded_assoc(model, next_state)])
        _    -> apply(ExShop.Order,
                      String.to_atom("#{next_state}_changeset"),
                      [with_preloaded_assoc(model, next_state), Dict.merge(%{"state" => next_state}, params)])
    end
  end

  def with_preloaded_assoc(model, "address") do
    ExShop.Repo.get!(Order, model.id)
    |> ExShop.Repo.preload([:shipping_address, :billing_address, :line_items])
  end

  def with_preloaded_assoc(model, "shipping") do
    ExShop.Repo.get!(Order, model.id)
    |> ExShop.Repo.preload([shippings: :shipping_method])
  end

  def with_preloaded_assoc(model, "tax") do
    ExShop.Repo.get!(Order, model.id)
    |> ExShop.Repo.preload([adjustments: [:tax, shipping: :shipping_method]])
  end

  def with_preloaded_assoc(model, "payment") do
    ExShop.Repo.get!(Order, model.id)
    |> ExShop.Repo.preload([payments: :payment_method])
  end

  def with_preloaded_assoc(model, "confirmation") do
    ExShop.Repo.get!(Order, model.id)
    |> ExShop.Repo.preload([line_items: :variant])
  end

  def with_preloaded_assoc(model, _) do
    model
  end

  def settle_adjustments_and_product_payments(model) do
    total =
      shipping_total(model)
      |> Decimal.add(tax_total(model))
      |> Decimal.add(product_total(model))

    model
    |> cast(%{total: total}, @required_fields, @optional_fields)
    |> ExShop.Repo.update!
  end

  def shipping_total(model) do
    selected_shipping_id = ExShop.Repo.all(from shipping in assoc(model, :shippings), where: shipping.selected, select: shipping.id)
    ExShop.Repo.one(
      from shipping_adj in assoc(model, :adjustments),
      where: shipping_adj.shipping_id in ^selected_shipping_id,
      select: sum(shipping_adj.amount)
    )
  end

  def tax_total(model) do
    ExShop.Repo.one(
      from tax_adj in assoc(model, :adjustments),
      where: not is_nil(tax_adj.tax_id),
      select: sum(tax_adj.amount)
    )
  end

  def product_total(model) do
    ExShop.Repo.one(
      from line_item in assoc(model, :line_items),
      select: sum(line_item.total)
    )
  end

  def acquire_variant_stock(model) do
    Enum.each(model.line_items, &ExShop.LineItem.acquire_stock_from_variant/1)
    model
  end

  def restock_unfullfilled_line_items(model) do
    Enum.each(model.line_items, &ExShop.LineItem.restock_variant/1)
    model
  end

  def address_changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> ensure_cart_is_not_empty
    |> cast_assoc(:shipping_address, required: true)
    |> cast_assoc(:billing_address, required: true)
  end

  # use this to set shipping
  def shipping_changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> cast_assoc(:shippings, required: true)
    |> ensure_only_one_shipping_selected
  end

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
    |> cast_assoc(:payments, required: true)
    |> ensure_only_one_payment_selected
  end

  # Check availability and othe stuff here
  def confirmation_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(confirm state), ~w())
    |> validate_order_confirmed
  end

  defp ensure_only_one_shipping_selected(model) do
    selected =
      get_field(model, :shippings)
      |> Enum.filter(&(&1.selected))
    case selected do
      []  -> add_error(model, :shippings, "Please select atleast one shipping method")
      [_] -> model
       _  -> add_error(model, :shippings, "Please select only 1 shipping method")
    end
  end

  defp ensure_only_one_payment_selected(model) do
    selected =
      get_field(model, :payments)
      |> Enum.filter(&(&1.selected))

    case selected do
      []  -> add_error(model, :payments, "Please select one payment method")
      [_] -> model
      _   -> add_error(model, :payments, "Please select only 1 payment method")
    end

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

end
