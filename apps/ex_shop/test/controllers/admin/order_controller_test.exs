defmodule ExShop.Admin.OrderControllerTest do
	use ExShop.ConnCase

  alias ExShop.Repo
  alias ExShop.Order
  alias ExShop.User

  setup(context) do
    do_setup(context)
  end

  test "list all orders", %{conn: conn} do
    conn = get conn, admin_order_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing Orders"
  end

  test "show order details", %{conn: conn} do
    order = Repo.insert! Order.cart_changeset(%Order{}, %{})
    conn = get conn, admin_order_path(conn, :show, order)
    assert html_response(conn, 200) =~ order.state
  end

  # CART Actions
  # TODO: implement after integration
  @tag :pending
  test "add to cart" do
    assert false
  end

  @tag :pending
  test "remove from cart" do
    assert false
  end

  @tag :pending
  test "update cart quantity" do
    assert false
  end

  @tag :pending
  test "add invalid quantity" do
    assert false
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
