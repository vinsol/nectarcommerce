require IEx

defmodule ExShop.Admin.CategoryController do
  use ExShop.Web, :controller

  alias ExShop.Category

  import Ecto.Query

  plug :scrub_params, "category" when action in [:create, :update]

  def index(conn, _params) do
    # categories = Category |>  order_by([c], asc: c.parent_id, asc: c.name) |> preload(:parent) |> Repo.all
    categories = Category |>  order_by([c],  asc: c.name) |>  preload(:parent) |> Repo.all
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
        adjust_tree_nodes
        conn
        |> put_flash(:info, "Category created successfully.")
        |> redirect(to: admin_category_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    category = Repo.get!(Category, id)
    descendants = Category.descendants(category) |> Repo.all
    ancestors = Category.ancestors(category) |> Repo.all
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
        adjust_tree_nodes
        conn
        |> put_flash(:info, "Category updated successfully.")
        |> redirect(to: admin_category_path(conn, :show, category))
      {:error, changeset} ->
        render(conn, "edit.html", category: category, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    category = Repo.get!(Category, id)

    Repo.transaction(fn ->
      # Delete all descendants, delete category and then recalculate left and right values for remaining nodes.
      # Deleting all descendants here because has_many :on_delete :delete_all just delete immediate children. No way to delete the complete subtree
      Category.descendants(category, %{ordered: false}) |> Repo.delete_all 
      Repo.delete!(category)
      adjust_tree_nodes
    end)

    conn
    |> put_flash(:info, "Category deleted successfully.")
    |> redirect(to: admin_category_path(conn, :index))
  end

  defp adjust_tree_nodes do
    root = Category.get_root_node |> Repo.one
    if root do
      Category.recalculate_lft_rgt(root, ExShop.Repo)
    end
  end

  defp get_categories_for_select  do
    Category 
      |> select([c], {c.name, c.id})  
      |> order_by(asc: :name)
      |> Repo.all
  end
  
end
