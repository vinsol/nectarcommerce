defmodule Nectar.Admin.ProductControllerTest do
  use Nectar.ConnCase

  alias Nectar.Repo
  alias Nectar.Product
  alias Nectar.User

  @product_attrs %{
    name: "Reebok Premium",
    description: "Reebok Premium Exclusively for you",
    available_on: Ecto.Date.utc
  }
  @master_variant_attrs %{
    master: %{
      cost_price: "20"
    }
  }
  @valid_attrs Map.merge(@product_attrs, @master_variant_attrs)
  @update_valid_attrs %{
    name: "Reebok Exclusive"
  }
  @invalid_attrs %{
    name: ""
  }

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
    conn = post conn, admin_product_path(conn, :create), product: @valid_attrs
    assert redirected_to(conn) == admin_product_path(conn, :index)
    assert Repo.get_by(Product, @product_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, admin_product_path(conn, :create), product: @invalid_attrs
    assert html_response(conn, 200) =~ "New product"
  end

  test "shows chosen resource", %{conn: conn} do
    product_changeset = Product.create_changeset(%Product{}, @valid_attrs)
    product = Repo.insert! product_changeset
    conn = get conn, admin_product_path(conn, :show, product)
    assert html_response(conn, 200) =~ "Show product"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, admin_product_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    product_changeset = Product.create_changeset(%Product{}, @valid_attrs)
    product = Repo.insert! product_changeset
    conn = get conn, admin_product_path(conn, :edit, product)
    assert html_response(conn, 200) =~ "Edit product"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    product_changeset = Product.create_changeset(%Product{}, @valid_attrs)
    product = Repo.insert! product_changeset
    conn = put conn, admin_product_path(conn, :update, product), product: @update_valid_attrs
    assert redirected_to(conn) == admin_product_path(conn, :show, product)
    assert Repo.get_by(Product, @update_valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    product_changeset = Product.create_changeset(%Product{}, @valid_attrs)
    product = Repo.insert! product_changeset
    conn = put conn, admin_product_path(conn, :update, product), product: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit product"
  end

  test "deletes chosen resource", %{conn: conn} do
    product = Repo.insert! %Product{}
    conn = delete conn, admin_product_path(conn, :delete, product)
    assert redirected_to(conn) == admin_product_path(conn, :index)
    refute Repo.get(Product, product.id)
  end

  @tag :pending
  test "Test Product with OptionTypes and product_option_types addition/deletion" do
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
