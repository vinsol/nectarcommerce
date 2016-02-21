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

    belongs_to :product, ExShop.Product
    has_many :variant_option_values, ExShop.VariantOptionValue, on_delete: :delete_all, on_replace: :delete
    has_many :option_values, through: [:variant_option_values, :option_value]

    timestamps
  end

  @required_fields ~w(is_master discontinue_on cost_price)
  @optional_fields ~w(sku weight height width depth cost_currency)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def variant_changeset(model, params \\ :empty) do
    changeset(model, params)
    |> put_change(:is_master, false)
    |> cast_attachments(params, ~w(), ~w(image))
    |> cast_assoc(:variant_option_values, required: true, with: &ExShop.VariantOptionValue.from_variant_changeset/2)
  end
end
