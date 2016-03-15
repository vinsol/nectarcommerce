defmodule Nectar.Admin.CategoryControllerTest do
  use Nectar.ConnCase

  alias Nectar.Category
  alias Nectar.Repo
  alias Nectar.User

  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  setup(context) do
    do_setup(context)
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, admin_category_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing categories"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, admin_category_path(conn, :new)
    assert html_response(conn, 200) =~ "New category"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, admin_category_path(conn, :create), category: @valid_attrs
    assert redirected_to(conn) == admin_category_path(conn, :index)
    assert Repo.get_by(Category, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, admin_category_path(conn, :create), category: @invalid_attrs
    assert html_response(conn, 200) =~ "New category"
  end

  test "shows chosen resource", %{conn: conn} do
    category = Repo.insert! %Category{}
    conn = get conn, admin_category_path(conn, :show, category)
    assert html_response(conn, 200) =~ "Show category"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, admin_category_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    category = Repo.insert! %Category{}
    conn = get conn, admin_category_path(conn, :edit, category)
    assert html_response(conn, 200) =~ "Edit category"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    category = Repo.insert! %Category{}
    conn = put conn, admin_category_path(conn, :update, category), category: @valid_attrs
    assert redirected_to(conn) == admin_category_path(conn, :show, category)
    assert Repo.get_by(Category, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    category = Repo.insert! %Category{}
    conn = put conn, admin_category_path(conn, :update, category), category: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit category"
  end

  test "deletes chosen resource", %{conn: conn} do
    category = Repo.insert! %Category{}
    conn = delete conn, admin_category_path(conn, :delete, category)
    assert redirected_to(conn) == admin_category_path(conn, :index)
    refute Repo.get(Category, category.id)
  end

  defp do_setup(%{nologin: _} = _context) do
    {:ok, %{conn: conn}}
  end

  defp do_setup(_context) do
    admin_user = Repo.insert!(%User{name: "Admin", email: "admin@vinsol.com", encrypted_password: Comeonin.Bcrypt.hashpwsalt("vinsol"), is_admin: true})
    conn = guardian_login(admin_user, :token, key: :admin)
    {:ok, %{conn: conn}}
  end

end
