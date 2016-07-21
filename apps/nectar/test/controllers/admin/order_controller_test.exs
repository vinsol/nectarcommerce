defmodule Nectar.Admin.OrderControllerTest do
  use Nectar.ConnCase

  alias Nectar.Repo

  setup(context) do
    do_setup(context)
  end

  test "list all orders", %{conn: conn} do
    conn = get conn, admin_order_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing Orders"
  end

  test "show order details", %{conn: conn} do
    order = Nectar.Command.Order.create_empty_cart_for_guest!(Repo)
    conn = get conn, admin_order_path(conn, :show, order)
    assert html_response(conn, 200) =~ order.state
  end

  defp do_setup(%{nologin: _} = _context) do
    {:ok, %{conn: conn}}
  end

  defp do_setup(_context) do
    {:ok, admin_user} = Nectar.TestSetup.User.create_admin
    conn = guardian_login(admin_user)
    {:ok, %{conn: conn}}
  end
end
