defmodule ExShop.CategoryController do
  use ExShop.Web, :controller

  alias ExShop.Product
  alias ExShop.Category

  def associated_products(conn, %{"category_id" => id}) do
    category = ExShop.Repo.get!(ExShop.Category, id) |> Repo.preload([products: Product.products_with_master_variant])
    products = category.products
    categories = ExShop.Repo.all(ExShop.Category.with_associated_products)
    render conn, "products.html", categories: categories, products: products
  end

end
