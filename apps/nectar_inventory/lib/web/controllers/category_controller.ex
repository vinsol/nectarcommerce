defmodule Nectar.CategoryController do
  use NectarCore.Web, :controller

  alias Nectar.Product
  alias Nectar.SearchProduct

  def associated_products(conn, %{"category_id" => id}) do
    category = Repo.get!(Nectar.Category, id) |> Repo.preload([products: Product.products_with_master_variant])
    products = category.products
    categories = Repo.all(Nectar.Category.with_associated_products)
    search_changeset = SearchProduct.changeset(%SearchProduct{})
    search_action = NectarRoutes.product_path(conn, :index)
    render conn, "products.html", categories: categories, products: products, search_action: search_action, search_changeset: search_changeset
  end

end
