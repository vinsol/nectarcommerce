defmodule ExShop.Order do
  use ExShop.Web, :model

  schema "orders" do
    field :slug, :string
    field :state, :string, default: "cart"
    has_many :line_items, ExShop.LineItem
    has_one  :shipping_address, ExShop.Address
    has_one  :billing_address, ExShop.Address
    has_many :order_adjustments, ExShop.Adjustment
    has_many :shippings, ExShop.Shipping

    has_many :products, through: [:line_items, :product]

    timestamps
  end

  @required_fields ~w(state)
  @optional_fields ~w(slug)

  @states ~w(cart address shipping taxes payment confirmation)

  def cart_changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def confirm_availability(model) do
    Enum.each(get_field(model, :line_items), &(LineItem.validate_product_availability &1))
  end

  # add addresses via this changeset
  # billing and shipping
  # constraint required

  def transition_changeset(model, next_state, params \\ :empty) do
    apply(
      ExShop.Order,
      String.to_atom("#{next_state}_changeset"),
      [model, %{params | state: next_state}]
    )
  end

  defp address_changeset(model, params \\ :empty) do
  end

  # use this to set shipping
  defp shipping_changeset(model, params \\ :empty) do
  end

  # use this to set tax adjustments
  defp taxes_changeset(model, params \\ :empty) do
  end

  # select payment
  defp payment_changeset(model, params \\ :empty) do
  end

  # Check availability and othe stuff here
  defp confirmation_changeset(model, params \\ :empty) do
  end

end
