defmodule Nectar.Category do
  use Nectar.Web, :model

  schema "categories" do
    field :name, :string
    belongs_to :parent, Nectar.Category
    has_many :children, Nectar.Category, foreign_key: :parent_id

    has_many :product_categories, Nectar.ProductCategory
    has_many :products, through: [:product_categories, :product]

    timestamps
    extensions
  end

  @required_fields ~w(name)a
  @optional_fields ~w(parent_id)a

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  def children_changeset(model, params \\ %{}) do
    changeset(model, params)
    |> cast_assoc(:children)
  end

  def leaf_categories do
    parent_ids = Nectar.Repo.all(from cat in Nectar.Category, where: not is_nil(cat.parent_id), select: cat.parent_id)
    from cat in Nectar.Category, where: not cat.id in ^parent_ids
  end

  def with_associated_products do
    from cat in Nectar.Category,
    join: p_cat in assoc(cat, :product_categories),
    select: cat,
    distinct: cat.id
  end
end
