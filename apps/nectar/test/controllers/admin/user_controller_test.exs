defmodule Nectar.UserControllerTest do
  use Nectar.ConnCase

  alias Nectar.Repo
  alias Nectar.User

  @valid_attrs %{email: "test@vinsol.com", name: "test", password: "vinsol", password_confirmation: "vinsol"}
  @invalid_attrs %{}

  setup(context) do
    do_setup(context)
  end

  @tag nologin: true
  test "should redirect if not logged in", %{conn: conn} do
    conn = get conn, admin_user_path(conn, :index)
    assert html_response(conn, 302)
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, admin_user_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing users"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, admin_user_path(conn, :new)
    assert html_response(conn, 200) =~ "New user"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, admin_user_path(conn, :create), user: @valid_attrs
    assert redirected_to(conn) == admin_user_path(conn, :index)
    assert Repo.get_by(User, email: @valid_attrs.email)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, admin_user_path(conn, :create), user: @invalid_attrs
    assert html_response(conn, 200) =~ "New user"
  end

  test "shows chosen resource", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = get conn, admin_user_path(conn, :show, user)
    assert html_response(conn, 200) =~ "Show user"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, admin_user_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = get conn, admin_user_path(conn, :edit, user)
    assert html_response(conn, 200) =~ "Edit user"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = put conn, admin_user_path(conn, :update, user), user: Map.merge(@valid_attrs, %{"is_admin" => true})
    assert redirected_to(conn) == admin_user_path(conn, :show, user)
    assert Repo.get_by(User, email: @valid_attrs.email, is_admin: true)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = put conn, admin_user_path(conn, :update, user), user: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit user"
  end

  test "deletes chosen resource", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = delete conn, admin_user_path(conn, :delete, user)
    assert redirected_to(conn) == admin_user_path(conn, :index)
    refute Repo.get(User, user.id)
  end

  defp do_setup(%{nologin: _} = _context) do
    {:ok, %{conn: build_conn()}}
  end

  defp do_setup(_context) do
    admin_user = Repo.insert!(%User{name: "Admin", email: "admin@vinsol.com", encrypted_password: Comeonin.Bcrypt.hashpwsalt("vinsol"), is_admin: true})
    conn = guardian_login(admin_user, :token, key: :admin)
    {:ok, %{conn: conn}}
  end
end
