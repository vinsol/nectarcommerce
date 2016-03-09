defmodule ExShop.ProductCategory do
  use ExShop.Web, :model

  schema "product_categories" do
    belongs_to :product, ExShop.Product
    belongs_to :category, ExShop.Category

    timestamps
  end

  @required_fields ~w()
  @optional_fields ~w(category_id)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def multi_category_changeset(model, params \\ :empty) do
    import IEx
    IEx.pry
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
