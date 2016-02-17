defmodule ExShop.NotProduct do
  use ExShop.Web, :model

  schema "not_products" do
    field :name, :string
    field :quantity, :integer
    field :cost, :decimal

    has_many :line_items, ExShop.LineItem, foreign_key: :product_id
  end

  @required_fields ~w(name quantity cost)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def quantity(query) do
    from c in query, select: c.quantity
  end

end
