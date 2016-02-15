defmodule ExShop.Order do
  use ExShop.Web, :model

  alias __MODULE__

  schema "orders" do
    field :slug, :string
    field :state, :string, default: "cart"
    has_many :line_items, ExShop.LineItem
    has_one  :shipping_address, ExShop.Address
    has_one  :billing_address, ExShop.Address
    has_many :adjustments, ExShop.Adjustment
    has_many :shippings, ExShop.Shipping
    field    :confirm, :boolean, virtual: true
    has_many :products, through: [:line_items, :product]
    has_many :payments, ExShop.Payment

    timestamps
  end

  @required_fields ~w(state)
  @optional_fields ~w(slug)

  @states ~w(cart address shipping tax payment confirmation)

  def cart_changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def confirm_availability(model) do
    line_items =
      ExShop.LineItem
      |> ExShop.LineItem.in_order(model)
      |> ExShop.Repo.all
      |> ExShop.Repo.preload(:product)
    %Order{model | line_items: Enum.map(line_items, &(ExShop.LineItem.validate_product_availability(&1)))}
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
    model
    |> ExShop.Repo.preload([:shipping_address, :billing_address])
  end

  def with_preloaded_assoc(model, "shipping") do
    model
    |> ExShop.Repo.preload([:shippings])
  end

  def with_preloaded_assoc(model, "payment") do
    model
    |> ExShop.Repo.preload([:payments])
  end

  def with_preloaded_assoc(model, _) do
    model
  end

  def settle_adjustments(model) do
    # calculate the final total here
  end

  def address_changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
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
    |> cast(params, @required_fields, @optional_fields)
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
    |> cast(params, [:confirm], [])
    |> validate_order_confirmed
  end

  defp ensure_only_one_shipping_selected(model) do
    selected_count =
      get_field(model, :shippings)
      |> Enum.filter(&(&1.selected))
      |> List.length

    if selected_count != 1 do
      add_error(model, :shippings, "Please select only 1 shipping method")
    else
      model
    end
  end

  defp ensure_only_one_payment_selected(model) do
    selected_count =
      get_field(model, :payments)
      |> Enum.filter(&(&1.selected))
      |> List.length

    if selected_count != 1 do
      add_error(model, :shippings, "Please select 1 payment method")
    else
      model
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

end
