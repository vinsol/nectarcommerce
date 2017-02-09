defmodule Nectar.ModelExtension do
  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :method_block, accumulate: true)
      import Nectar.ModelExtension, only: [include_method: 1]
      @before_compile Nectar.ModelExtension

      defmacro __using__(_opts) do
        quote do
          import Nectar.ExtendProduct, only: [include_methods: 0]
          @before_compile Nectar.ExtendProduct
        end
      end
    end
  end

  defmacro include_method([do: block]) do
    support_fn = Macro.escape(block)
    quote bind_quoted: [support_fn: support_fn] do
      Module.put_attribute(__MODULE__, :method_block, support_fn)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      defmacro include_methods do
        @method_block
      end

      ## before_compile hook as needed in ExtendProduct for Product
      defmacro __before_compile__(_env) do
        quote do
          include_methods
        end
      end
    end
  end
end

defmodule Nectar.ExtendProduct do
  use Nectar.ModelExtension

  include_method do: (def fn_from_outside, do: "support function")
  include_method do: (def get_name(product), do: product.name)
end

defmodule Nectar.Product do
  use Nectar.Web, :model
  use Arc.Ecto.Model

  use Nectar.ExtendProduct

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

    extensions()
    timestamps()
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
    |> cast_assoc(:product_option_types, with: &Nectar.ProductOptionType.from_product_changeset/2)
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
