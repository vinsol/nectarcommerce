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
    search(Product, params)
  end
  def search(queryable, params) do
    queryable
      |> search_name(params)
      |> search_description(params)
  end

  defp search_name(queryable, %{"name" => name}) when (is_nil(name) or name == "") do
    queryable
  end
  defp search_name(queryable, %{"name" => name}) do
    from p in queryable,
      where: ilike(p.name, ^("%#{name}%"))
  end
  defp search_name(queryable, params) do
    queryable
  end

  defp search_description(queryable, %{"description" => description}) when (is_nil(description) or description == "") do
    queryable
  end
  defp search_description(queryable, %{"description" => description}) do
    from p in queryable,
      where: ilike(p.description, ^("%#{description}%"))
  end
  defp search_description(queryable, params) do
    queryable
  end
end
