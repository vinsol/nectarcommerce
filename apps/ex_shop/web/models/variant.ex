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

    timestamps
  end

  @required_fields ~w(is_master sku weight height width depth discontinue_on cost_price cost_currency)
  @optional_fields ~w(image)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
