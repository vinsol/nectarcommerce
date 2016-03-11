defmodule ExShop.ProductController do
  use ExShop.Web, :controller

  alias ExShop.Product

  def index(conn, _params) do
    products = ExShop.Repo.all(ExShop.Product.products_with_master_variant)
    categories = ExShop.Repo.all(ExShop.Category.with_associated_products)
    render conn, "index.html", products: products, categories: categories
  end

  def show(conn, %{"id" => id}) do
    product = Repo.one(Product.product_with_variants(id))
    render(conn, "show.html", product: product)
  end

end
