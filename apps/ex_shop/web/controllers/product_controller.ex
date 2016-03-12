defmodule ExShop.ProductController do
  use ExShop.Web, :controller

  alias ExShop.Product
  alias ExShop.SearchProduct

  def index(conn, %{"search_product" => search_params} = params) do
    categories = ExShop.Repo.all(ExShop.Category.with_associated_products)
    products = Repo.all(SearchProduct.search(Product.products_with_master_variant, search_params))
    render(conn, "index.html", products: products, categories: categories,
      search_changeset: SearchProduct.changeset(%SearchProduct{}, search_params),
      search_action: product_path(conn, :index)
    )
  end
  def index(conn, _params) do
    categories = ExShop.Repo.all(ExShop.Category.with_associated_products)
    products = Repo.all(Product.products_with_master_variant)
    render(conn, "index.html", products: products, categories: categories,
      search_changeset: SearchProduct.changeset(%SearchProduct{}),
      search_action: product_path(conn, :index)
    )
  end

  def show(conn, %{"id" => id}) do
    product = Repo.one(Product.product_with_variants(id))
    render(conn, "show.html", product: product)
  end

end
