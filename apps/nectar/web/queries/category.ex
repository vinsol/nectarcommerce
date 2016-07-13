defmodule Nectar.Query.Category do
  use Nectar.Query, model: Nectar.Category
  def parent_ids do
    from cat in Nectar.Category,
      where: not is_nil(cat.parent_id),
      select: cat.parent_id
  end

  def with_associated_products do
    from cat in Nectar.Category,
    join: p_cat in assoc(cat, :product_categories),
    select: cat,
    distinct: cat.id
  end

  def leaf_categories(parent_ids) when is_list(parent_ids), do: from cat in Nectar.Category, where: not cat.id in ^parent_ids
  def leaf_categories(repo) do
    repo.all(parent_ids)
    |> leaf_categories
    |> repo.all
  end
  def with_associated_products(repo), do: repo.all(with_associated_products)

end
