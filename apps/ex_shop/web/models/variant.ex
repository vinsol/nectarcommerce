defmodule ExShop.Variant do
  use ExShop.Web, :model

  schema "variants" do
    field :is_master, :boolean, default: false
    field :sku, :string
    field :weight, :integer
    field :height, :integer
    field :width, :integer
    field :depth, :integer
    field :discontinue_on, Ecto.DateTime
    field :cost_price, :decimal
    field :cost_currency, :string
    belongs_to :product, ExShop.Product

    timestamps
  end

  @required_fields ~w(is_master sku weight height width depth discontinue_on cost_price cost_currency)
  @optional_fields ~w()

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
