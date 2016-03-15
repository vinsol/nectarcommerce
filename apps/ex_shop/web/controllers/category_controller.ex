defmodule ExShop.CategoryController do
  use ExShop.Web, :controller

  alias ExShop.Product
  alias ExShop.SearchProduct

  def associated_products(conn, %{"category_id" => id}) do
    category = ExShop.Repo.get!(ExShop.Category, id) |> Repo.preload([products: Product.products_with_master_variant])
    products = category.products
    categories = ExShop.Repo.all(ExShop.Category.with_associated_products)
    search_changeset = SearchProduct.changeset(%SearchProduct{})
    search_action = product_path(conn, :index)
    render conn, "products.html", categories: categories, products: products, search_action: search_action, search_changeset: search_changeset
  end

end
