defmodule ExShop.Variant do
  use ExShop.Web, :model
  use Arc.Ecto.Model

  schema "variants" do
    field :is_master, :boolean, default: false
    field :sku, :string
    field :weight, :decimal
    field :height, :decimal
    field :width, :decimal
    field :depth, :decimal
    field :discontinue_on, Ecto.Date
    field :cost_price, :decimal
    field :cost_currency, :string
    field :image, ExShop.VariantImage.Type

    field :total_quantity, :integer, default: 0
    field :add_count, :integer, virtual: true

    field :bought_quantity, :integer, default: 0
    field :buy_count, :integer, virtual: true

    field :restock_count, :integer, virtual: true

    belongs_to :product, ExShop.Product
    has_many :variant_option_values, ExShop.VariantOptionValue, on_delete: :delete_all, on_replace: :delete
    has_many :option_values, through: [:variant_option_values, :option_value]

    has_many :line_items, ExShop.LineItem

    timestamps
  end

  @required_fields ~w(is_master discontinue_on cost_price)
  @optional_fields ~w(sku weight height width depth cost_currency add_count)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> update_total_quantity
  end

  def variant_changeset(model, params \\ :empty) do
    changeset(model, params)
    |> put_change(:is_master, false)
    |> cast_attachments(params, ~w(), ~w(image))
    |> cast_assoc(:variant_option_values, required: true, with: &ExShop.VariantOptionValue.from_variant_changeset/2)
  end

  def buy_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(buy_count), ~w())
    |> increment_bought_quantity
  end

  def restocking_changeset(model, params) do
    model
    |> cast(params, ~w(restock_count), ~w())
    |> decrement_bought_quantity
  end

  defp update_total_quantity(model) do
    quantity_to_add = model.changes[:add_count]
    if quantity_to_add do
      put_change(model, :total_quantity, model.model.total_quantity + quantity_to_add)
    else
      model
    end
  end

  defp increment_bought_quantity(model) do
    quantity_to_add = model.changes[:buy_count]
    if quantity_to_add do
      put_change(model, :bought_quantity, (model.model.bought_quantity || 0) + quantity_to_add)
    else
      model
    end
  end

  defp decrement_bought_quantity(model) do
    quantity_to_subtract = model.changes[:restock_count]
    if quantity_to_subtract do
      put_change(model, :bought_quantity, (model.model.bought_quantity || 0) - quantity_to_subtract)
    else
      model
    end
  end

  def available_quantity(%ExShop.Variant{total_quantity: total_quantity, bought_quantity: bought_quantity}) when is_nil(bought_quantity) do
    total_quantity
  end

  def available_quantity(%ExShop.Variant{total_quantity: total_quantity, bought_quantity: bought_quantity}) do
    total_quantity - bought_quantity
  end

end
