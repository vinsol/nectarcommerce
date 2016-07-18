defmodule Nectar.Admin.CategoryController do
  use Nectar.Web, :admin_controller

  alias Nectar.Category

  plug :scrub_params, "category" when action in [:create, :update]

  def index(conn, _params) do
    categories = Nectar.Query.Category.all(Repo)
    render(conn, "index.html", categories: categories)
  end

  def new(conn, _params) do
    changeset = Category.changeset(%Category{})
    categories = Nectar.Query.Category.names_and_id(Repo)
    render(conn, "new.html", changeset: changeset, categories: categories)
  end

  def create(conn, %{"category" => category_params}) do
    case Nectar.Command.Category.insert(Repo, category_params) do
      {:ok, _category} ->
        conn
        |> put_flash(:info, "Category created successfully.")
        |> redirect(to: admin_category_path(conn, :index))
      {:error, changeset} ->
        categories = Nectar.Query.Category.names_and_id(Repo)
        render(conn, "new.html", changeset: changeset, categories: categories)
    end
  end

  def show(conn, %{"id" => id}) do
    category =
      Nectar.Query.Category.get!(Repo, id)
      |> Repo.preload([:parent])

    render(conn, "show.html", category: category)
  end

  def edit(conn, %{"id" => id}) do
    category = Nectar.Query.Category.get!(Repo, id)
    categories = Nectar.Query.Category.names_and_id_excluding_id(Repo, id)
    changeset = Category.changeset(category)
    render(conn, "edit.html", category: category, changeset: changeset, categories: categories)
  end

  def update(conn, %{"id" => id, "category" => category_params}) do
    category = Nectar.Query.Category.get!(Repo, id)
    case Nectar.Command.Category.update(Repo, category, category_params) do
      {:ok, category} ->
        conn
        |> put_flash(:info, "Category updated successfully.")
        |> redirect(to: admin_category_path(conn, :show, category))
      {:error, changeset} ->
        categories = Nectar.Query.Category.names_and_id_excluding_id(Repo, id)
        render(conn, "edit.html", category: category, changeset: changeset, categories: categories)
    end
  end

  def delete(conn, %{"id" => id}) do
    category = Nectar.Query.Category.get!(Repo, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Nectar.Command.Category.delete!(Repo, category)

    conn
    |> put_flash(:info, "Category deleted successfully.")
    |> redirect(to: admin_category_path(conn, :index))
  end
end
