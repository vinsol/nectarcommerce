defmodule ExShop.SearchProduct do
  use ExShop.Web, :model

  alias ExShop.Product

  schema "abstract table:search_product" do
    field :name, :string, virtual: true
  end

  def changeset(model, params \\ :empty) do
    model
      |> cast(params, ~w(), ~w(name))
  end

  def search(params) do
    Product
      |> search_name(params)
  end

  defp search_name(queryable, %{"name" => name}) when (is_nil(name) or name == "") do
    queryable
  end
  defp search_name(queryable, %{"name" => name}) do
    from p in queryable,
      where: ilike(p.name, ^("%#{name}%"))
  end
end
