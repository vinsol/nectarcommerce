defmodule ExShop.Category do
  use ExShop.Web, :model

  schema "categories" do
    field :name, :string
    field :parent_id, :integer, default: 0
    field :lft, :integer
    field :rgt, :integer

    has_many :children, ExShop.Category, [foreign_key: :parent_id]

    timestamps
  end

  @required_fields ~w(name)
  @optional_fields ~w(parent_id lft rgt)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def nested_set_changeset(model, params ) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def ordered(query, field) do
    from c in query, order_by: ^field
  end

  def sub_categories(category) do
    assoc(category, :children) 
      |> ordered(:name) 
  end

end
