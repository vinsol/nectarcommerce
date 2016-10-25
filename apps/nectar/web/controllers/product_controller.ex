defmodule Nectar.ProductController do
  use Nectar.Web, :controller

  alias Nectar.Query
  alias Nectar.SearchProduct

  def index(conn, %{"search_product" => search_params} = _params) do
    categories = Query.Category.with_associated_products(Repo)
    products = Repo.all(SearchProduct.search(Nectar.Query.Product.products_with_master_variant, search_params))
    render(conn, "index.html", products: products, categories: categories,
      search_changeset: SearchProduct.changeset(%SearchProduct{}, search_params),
      search_action: product_path(conn, :index)
    )
  end

  def index(conn, _params) do
    categories = Query.Category.with_associated_products(Repo)
    products   = Query.Product.products_with_master_variant(Repo)

    render(conn, "index.html", products: products, categories: categories,
      search_changeset: SearchProduct.changeset(%SearchProduct{}),
      search_action: product_path(conn, :index)
    )
  end

  def show(conn, %{"id" => id}) do
    product = Query.Product.product_with_variants(Repo, id)
    render(conn, "show.html", product: product)
  end

end
