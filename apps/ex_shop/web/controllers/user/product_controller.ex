defmodule ExShop.User.ProductController do
  use ExShop.Web, :controller

  alias ExShop.Product

  def index(conn, _params) do
    products = ExShop.Repo.all(ExShop.Product.products_with_master_variant)
    render conn, "index.html", products: products
  end

  def show(conn, %{"id" => id}) do
    product = Repo.one(Product.product_with_variants(id))
    render(conn, "show.html", product: product)
  end

end
