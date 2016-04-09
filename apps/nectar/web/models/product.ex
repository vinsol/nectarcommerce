defmodule Nectar.ModelExtension do
  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :schema_changes, accumulate: true)
      import Nectar.ModelExtension, only: [add_to_schema: 1]
      @before_compile Nectar.ModelExtension
    end
  end

  defmacro add_to_schema([do: block]) do
    schema_change = Macro.escape(block)
    quote bind_quoted: [schema_change: schema_change] do
      Module.put_attribute(__MODULE__, :schema_changes, schema_change)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      defmacro extensions do
        @schema_changes
      end
    end
  end
end

defmodule Nectar.ExtendProduct do
  use Nectar.ModelExtension

  add_to_schema do: (field :special, :boolean, virtual: true)
end

defmodule Nectar.Product do
  import Nectar.ExtendProduct

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

    has_many :product_option_types, Nectar.ProductOptionType
    has_many :option_types, through: [:product_option_types, :option_type]

    has_many :product_categories, Nectar.ProductCategory
    has_many :categories, through: [:product_categories, :category]

    extensions
    timestamps
  end

  @required_fields ~w(name description available_on)
  @optional_fields ~w(slug special)

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
    |> Validations.Date.validate_not_past_date(:available_on)
    |> Nectar.Slug.generate_slug()
    |> cast_assoc(:master, required: true, with: &Nectar.Variant.create_master_changeset/2)
    |> cast_assoc(:product_option_types, required: true, with: &Nectar.ProductOptionType.from_product_changeset/2)
    |> cast_assoc(:product_categories, with: &Nectar.ProductCategory.from_product_changeset/2)
    |> unique_constraint(:slug)
  end

  def update_changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> Validations.Date.validate_not_past_date(:available_on)
    |> Nectar.Slug.generate_slug()
    |> cast_assoc(:product_categories, with: &Nectar.ProductCategory.from_product_changeset/2)
    |> cast_assoc(:master, required: true, with: &Nectar.Variant.update_master_changeset/2)
    |> validate_available_on_lt_discontinue_on
    |> cast_assoc(:product_option_types, required: true, with: &Nectar.ProductOptionType.from_product_changeset/2)
    |> unique_constraint(:slug)
  end

  defp validate_available_on_lt_discontinue_on(changeset) do
    changed_master = get_change(changeset, :master)
    changed_discontinue_on = if changed_master do
      get_change(changed_master, :discontinue_on) || changed_master.model.discontinue_on
    else
      changeset.model.master.discontinue_on
    end
    changeset
      |> Validations.Date.validate_lt_date(:available_on, changed_discontinue_on)
  end

  def has_variants_excluding_master?(product) do
    Nectar.Repo.one(from variant in all_variants(product), select: count(variant.id)) > 0
  end

  def variant_count(product) do
    Nectar.Repo.one(from variant in all_variants_including_master(product), select: count(variant.id))
  end

  def master_variant(model) do
    from variant in all_variants_including_master(model), where: variant.is_master
  end

  def all_variants(model) do
    from variant in all_variants_including_master(model), where: not(variant.is_master)
  end

  def all_variants_including_master(model) do
    from variant in assoc(model, :variants)
  end

  # helper queries for preloading variant data.
  @master_query  from m in Nectar.Variant, where: m.is_master
  @variant_query from m in Nectar.Variant, where: not(m.is_master), preload: [option_values: :option_type]

  def products_with_master_variant do
    from p in Nectar.Product, preload: [master: ^@master_query]
  end

  def products_with_variants do
    from p in Nectar.Product, preload: [master: ^@master_query, variants: ^@variant_query]
  end

  def product_with_master_variant(product_id) do
    from p in Nectar.Product,
    where: p.id == ^product_id,
    preload: [master: ^@master_query]
  end

  def product_with_variants(product_id) do
    from p in Nectar.Product,
    where: p.id == ^product_id,
    preload: [variants: ^@variant_query, master: ^@master_query]
  end

end
