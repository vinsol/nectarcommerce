require IEx

defmodule ExShop.Admin.CategoryController do
  use ExShop.Web, :controller

  alias ExShop.Category

  import Ecto.Query

  plug :scrub_params, "category" when action in [:create, :update]

  def index(conn, _params) do
    categories = Category |>  order_by([c], asc: c.parent_id, asc: c.name) |> preload(:parent) |> Repo.all
    render(conn, "index.html", categories: categories)
  end

  def new(conn, _params) do
    changeset = Category.changeset(%Category{})
    render(conn, "new.html", changeset: changeset, categories_for_select: get_categories_for_select)
  end

  def create(conn, %{"category" => category_params}) do
    changeset = Category.changeset(%Category{}, category_params)

    case Repo.insert(changeset) do
      {:ok, _category} ->
        NestedSet.Category.recalculate_lft_rgt
        conn
        |> put_flash(:info, "Category created successfully.")
        |> redirect(to: admin_category_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    category = Repo.get!(Category, id)
    descendants = NestedSet.Category.descendants(category)
    ancestors = NestedSet.Category.ancestors(category)
    render(conn, "show.html", category: category, descendants: descendants, ancestors: ancestors)
  end

  def edit(conn, %{"id" => id}) do
    category = Repo.get!(Category, id)
    changeset = Category.changeset(category)
    render(conn, "edit.html", category: category, changeset: changeset, categories_for_select: get_categories_for_select)
  end

  def update(conn, %{"id" => id, "category" => category_params}) do
    category = Repo.get!(Category, id)
    changeset = Category.changeset(category, category_params)

    case Repo.update(changeset) do
      {:ok, category} ->
        NestedSet.Category.recalculate_lft_rgt
        conn
        |> put_flash(:info, "Category updated successfully.")
        |> redirect(to: admin_category_path(conn, :show, category))
      {:error, changeset} ->
        render(conn, "edit.html", category: category, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    category = Repo.get!(Category, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(category)
    NestedSet.Category.recalculate_lft_rgt
    conn
    |> put_flash(:info, "Category deleted successfully.")
    |> redirect(to: admin_category_path(conn, :index))
  end


  defp get_categories_for_select  do
    Category 
      |> select([c], {c.name, c.id})  
      |> Repo.all
  end
  
end
