defmodule ExShop.Product do
  use ExShop.Web, :model
  use Arc.Ecto.Model

  schema "products" do
    field :name, :string
    field :description, :string
    field :available_on, Ecto.Date
    field :discontinue_on, Ecto.Date
    field :slug, :string

    has_one :master, ExShop.Variant, on_delete: :nilify_all # As this and below association same, how to handle on_delete
    has_many :variants, ExShop.Variant, on_delete: :nilify_all

    has_many :product_option_types, ExShop.ProductOptionType
    has_many :option_types, through: [:product_option_types, :option_type]

    timestamps
  end

  @required_fields ~w(name description available_on)
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

  def create_changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> ExShop.Slug.generate_slug()
    |> cast_assoc(:master, required: true, with: &master_changeset/2)
    |> cast_assoc(:product_option_types, required: true, with: &ExShop.ProductOptionType.from_product_changeset/2)
    |> unique_constraint(:slug)
  end

  def master_changeset(model, params \\ :empty) do
    cast(model, params, ~w(cost_price), @optional_fields)
    |> put_change(:is_master, true)
    |> cast_attachments(params, ~w(), ~w(image))
  end
end
