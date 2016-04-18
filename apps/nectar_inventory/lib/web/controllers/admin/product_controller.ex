defmodule Nectar.Admin.ProductController do
  use Nectar.Web, :admin_controller

  alias Nectar.Product
  alias Nectar.OptionType
  alias Nectar.Category
  alias Nectar.SearchProduct

  plug Guardian.Plug.EnsureAuthenticated, handler: Nectar.Auth.HandleAdminUnauthenticated, key: :admin

  plug :scrub_params, "product" when action in [:create, :update]
  plug :load_categories_and_option_types when action in [:create, :new, :edit, :update]

  def index(conn, %{"search_product" => search_params} = _params) do
    products = Repo.all(SearchProduct.search(search_params))
    render(conn, "index.html", products: products,
      search_changeset: SearchProduct.changeset(%SearchProduct{}, search_params),
      search_action: admin_product_path(conn, :index)
    )
  end
  def index(conn, _params) do
    products = Repo.all(Product)
    render(conn, "index.html", products: products,
      search_changeset: SearchProduct.changeset(%SearchProduct{}),
      search_action: admin_product_path(conn, :index)
    )
  end

  def new(conn, _params) do
    changeset = Product.changeset(%Product{available_on: Ecto.Date.utc})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"product" => product_params}) do
    changeset = Product.create_changeset(%Product{}, product_params)
    case Repo.insert(changeset) do
      {:ok, _product} ->
        conn
        |> put_flash(:info, "Product created successfully.")
        |> redirect(to: admin_product_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    product = Repo.get!(Product, id) |> Repo.preload([:master, :option_types, :categories])
    render(conn, "show.html", product: product)
  end

  def edit(conn, %{"id" => id}) do
    product = Repo.get!(Product, id) |> Repo.preload([:master, :product_option_types, :product_categories])
    changeset = Product.changeset(product)
    render(conn, "edit.html", product: product, changeset: changeset)
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    product = Repo.get!(Product, id) |> Repo.preload([:master, :product_option_types, :product_categories])
    changeset = Product.update_changeset(product, product_params)

    case Repo.update(changeset) do
      {:ok, product} ->
        conn
        |> put_flash(:info, "Product updated successfully.")
        |> redirect(to: admin_product_path(conn, :show, product))
      {:error, changeset} ->
        render(conn, "edit.html", product: product, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    product = Repo.get!(Product, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(product)

    conn
    |> put_flash(:info, "Product deleted successfully.")
    |> redirect(to: admin_product_path(conn, :index))
  end

  defp load_categories_and_option_types(conn, _params) do
    get_option_types = Repo.all(from strct in OptionType, select: {strct.name, strct.id})
    categories = Repo.all(from strct in Category.leaf_categories, select: {strct.name, strct.id})
    conn
    |> assign(:get_option_types, get_option_types)
    |> assign(:categories, categories)
  end

end
