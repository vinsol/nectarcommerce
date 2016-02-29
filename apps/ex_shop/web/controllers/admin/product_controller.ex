defmodule ExShop.Admin.ProductController do
  use ExShop.Web, :admin_controller

  alias ExShop.Product
  alias ExShop.OptionType

  plug Guardian.Plug.EnsureAuthenticated, handler: ExShop.Auth.HandleUnauthenticated, key: :admin

  plug :scrub_params, "product" when action in [:create, :update]

  def index(conn, _params) do
    products = Repo.all(Product)
    render(conn, "index.html", products: products)
  end

  def new(conn, _params) do
    changeset = Product.changeset(%Product{})
    get_option_types = Repo.all(OptionType) |> Enum.map(fn(x) -> {x.name, x.id} end)
    render(conn, "new.html", changeset: changeset, get_option_types: get_option_types)
  end

  def create(conn, %{"product" => product_params}) do
    changeset = Product.create_changeset(%Product{}, product_params)
    get_option_types = Repo.all(OptionType) |> Enum.map(fn(x) -> {x.name, x.id} end)

    case Repo.insert(changeset) do
      {:ok, _product} ->
        conn
        |> put_flash(:info, "Product created successfully.")
        |> redirect(to: admin_product_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, get_option_types: get_option_types)
    end
  end

  def show(conn, %{"id" => id}) do
    product = Repo.get!(Product, id) |> Repo.preload([:master, :option_types])
    render(conn, "show.html", product: product)
  end

  def edit(conn, %{"id" => id}) do
    product = Repo.get!(Product, id) |> Repo.preload([:master, :product_option_types])
    get_option_types = Repo.all(OptionType) |> Enum.map(fn(x) -> {x.name, x.id} end)
    changeset = Product.changeset(product)
    render(conn, "edit.html", product: product, changeset: changeset, get_option_types: get_option_types)
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    product = Repo.get!(Product, id) |> Repo.preload([:master, :product_option_types])
    get_option_types = Repo.all(OptionType) |> Enum.map(fn(x) -> {x.name, x.id} end)
    changeset = Product.update_changeset(product, product_params)

    case Repo.update(changeset) do
      {:ok, product} ->
        conn
        |> put_flash(:info, "Product updated successfully.")
        |> redirect(to: admin_product_path(conn, :show, product))
      {:error, changeset} ->
        render(conn, "edit.html", product: product, changeset: changeset, get_option_types: get_option_types)
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
end
