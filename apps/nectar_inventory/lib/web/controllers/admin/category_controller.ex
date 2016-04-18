defmodule Nectar.Admin.CategoryController do
  use NectarCore.Web, :admin_controller

  alias Nectar.Category

  plug Guardian.Plug.EnsureAuthenticated, handler: Nectar.Auth.HandleAdminUnauthenticated, key: :admin

  plug :scrub_params, "category" when action in [:create, :update]

  def index(conn, _params) do
    categories = Repo.all(Category)
    render(conn, "index.html", categories: categories)
  end

  def new(conn, _params) do
    changeset = Category.changeset(%Category{})
    categories = Repo.all(from c in Category, select: {c.name, c.id})
    render(conn, "new.html", changeset: changeset, categories: categories)
  end

  def create(conn, %{"category" => category_params}) do
    changeset = Category.changeset(%Category{}, category_params)
    categories = Repo.all(from c in Category, select: {c.name, c.id})

    case Repo.insert(changeset) do
      {:ok, _category} ->
        conn
        |> put_flash(:info, "Category created successfully.")
        |> redirect(to: NectarRoutes.admin_category_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, categories: categories)
    end
  end

  def show(conn, %{"id" => id}) do
    category = Repo.get!(Category, id) |> Repo.preload([:parent])
    render(conn, "show.html", category: category)
  end

  def edit(conn, %{"id" => id}) do
    category = Repo.get!(Category, id)
    categories = Repo.all(from c in Category, select: {c.name, c.id}, where: c.id != ^id)
    changeset = Category.changeset(category)
    render(conn, "edit.html", category: category, changeset: changeset, categories: categories)
  end

  def update(conn, %{"id" => id, "category" => category_params}) do
    category = Repo.get!(Category, id)
    changeset = Category.changeset(category, category_params)
    categories = Repo.all(from c in Category, select: {c.name, c.id}, where: c.id != ^id)

    case Repo.update(changeset) do
      {:ok, category} ->
        conn
        |> put_flash(:info, "Category updated successfully.")
        |> redirect(to: NectarRoutes.admin_category_path(conn, :show, category))
      {:error, changeset} ->
        render(conn, "edit.html", category: category, changeset: changeset, categories: categories)
    end
  end

  def delete(conn, %{"id" => id}) do
    category = Repo.get!(Category, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(category)

    conn
    |> put_flash(:info, "Category deleted successfully.")
    |> redirect(to: NectarRoutes.admin_category_path(conn, :index))
  end
end
