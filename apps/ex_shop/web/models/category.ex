defmodule ExShop.Category do
  use ExShop.Web, :model

  schema "categories" do
    field :name, :string
    belongs_to :parent, ExShop.Category
    has_many :children, ExShop.Category, foreign_key: :parent_id

    has_many :product_categories, ExShop.ProductCategory

    timestamps
  end

  @required_fields ~w(name)
  @optional_fields ~w(parent_id)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def children_changeset(model, params \\ :empty) do
    changeset(model, params)
    |> cast_assoc(:children)
  end

  def leaf_categories do
    parent_ids = ExShop.Repo.all(from cat in ExShop.Category, where: not is_nil(cat.parent_id), select: cat.parent_id)
    leaf = (from cat in ExShop.Category, where: not cat.id in ^parent_ids)
  end
end
