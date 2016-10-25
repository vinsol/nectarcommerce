defmodule Nectar.Admin.ProductControllerTest do
  use Nectar.ConnCase

  setup(context) do
    do_setup(context)
  end

  @tag nologin: true
  test "should redirect if not logged in", %{conn: conn} do
    conn = get conn, admin_product_path(conn, :index)
    assert html_response(conn, 302)
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, admin_product_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing products"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, admin_product_path(conn, :new)
    assert html_response(conn, 200) =~ "New product"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, admin_product_path(conn, :create), product: Nectar.TestSetup.Product.valid_attrs_with_option_type
    assert redirected_to(conn) == admin_product_path(conn, :index)
    refute Nectar.Query.Product.all(Repo) == []
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, admin_product_path(conn, :create), product: Nectar.TestSetup.Product.invalid_attrs
    assert html_response(conn, 200) =~ "New product"
  end

  test "shows chosen resource", %{conn: conn} do
    product = Nectar.TestSetup.Product.create_product
    conn = get conn, admin_product_path(conn, :show, product)
    assert html_response(conn, 200) =~ "Show product"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, admin_product_path(conn, :show, -1)
    end
  end

  @tag :nologin
  test "redirects to login page if not logged in", %{conn: conn} do
    conn = get conn, admin_product_path(conn, :show, -1)
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    product = Nectar.TestSetup.Product.create_product
    conn = get conn, admin_product_path(conn, :edit, product)
    assert html_response(conn, 200) =~ "Edit product"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    product = Nectar.TestSetup.Product.create_product
    conn = put conn, admin_product_path(conn, :update, product), product: %{name: product.name <> "change"}
    assert redirected_to(conn) == admin_product_path(conn, :show, product)
    assert Nectar.Query.Product.get!(Repo, product.id).name == product.name <> "change"
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    product = Nectar.TestSetup.Product.create_product
    conn = put conn, admin_product_path(conn, :update, product), product: %{name: ""}
    assert html_response(conn, 200) =~ "Edit product"
  end

  test "deletes chosen resource", %{conn: conn} do
    product = Nectar.TestSetup.Product.create_product
    conn = delete conn, admin_product_path(conn, :delete, product)
    assert redirected_to(conn) == admin_product_path(conn, :index)
    refute Nectar.Query.Product.get(Repo, product.id)
  end

  @tag :pending
  test "Test Product with OptionTypes and product_option_types addition/deletion" do
  end

  defp do_setup(%{nologin: _} = _context) do
    {:ok, %{conn: build_conn()}}
  end

  defp do_setup(_context) do
    {:ok, admin_user} = Nectar.TestSetup.User.create_admin
    conn = guardian_login(admin_user)
    {:ok, %{conn: conn}}
  end
end
