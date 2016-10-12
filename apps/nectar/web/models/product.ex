defmodule Nectar.Product do
  use Nectar.Web, :model
  use Arc.Ecto.Model

  schema "products" do
    field :name, :string
    field :description, :string
    field :available_on, Ecto.Date
    field :discontinue_on, Ecto.Date
    field :slug, :string

    has_one :master, Nectar.Variant, on_delete: :nilify_all # As this and below association same, how to handle on_delete
    has_many :variants, Nectar.Variant, on_delete: :nilify_all

    has_many :product_option_types, Nectar.ProductOptionType, on_delete: :nilify_all
    has_many :option_types, through: [:product_option_types, :option_type]

    has_many :product_categories, Nectar.ProductCategory, on_delete: :nilify_all
    has_many :categories, through: [:product_categories, :category]

    extensions
    timestamps
  end

  @required_fields ~w(name description available_on)a
  @optional_fields ~w(slug)a

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> Validations.Date.validate_not_past_date(:available_on)
    |> Nectar.Slug.generate_slug()
    |> cast_assoc(:product_option_types, required: true, with: &Nectar.ProductOptionType.from_product_changeset/2)
    |> cast_assoc(:product_categories, with: &Nectar.ProductCategory.from_product_changeset/2)
    |> unique_constraint(:slug)
  end

  def create_changeset(model, params \\ %{}) do
    changeset(model, params)
    |> cast_assoc(:master, required: true, with: &Nectar.Variant.create_master_changeset/2)
  end

  def update_changeset(model, params \\ %{}) do
    changeset(model, params)
    |> cast_assoc(:master, required: true, with: &(Nectar.Variant.update_master_changeset(&1, model, &2)))
    |> validate_available_on_lt_discontinue_on
  end

  defp validate_available_on_lt_discontinue_on(changeset) do
    changeset
    |> Validations.Date.validate_lt_date(:available_on, changed_discontinue_on(changeset))
  end

  defp changed_discontinue_on(changeset) do
    changed_master = get_change(changeset, :master)
    if changed_master do
      get_change(changed_master, :discontinue_on) || changed_master.data.discontinue_on
    else
      changeset.data.master.discontinue_on
    end
  end

end
