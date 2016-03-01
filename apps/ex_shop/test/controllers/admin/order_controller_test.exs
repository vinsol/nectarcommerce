defmodule ExShop.Admin.OrderControllerTest do
	use ExShop.ConnCase

  alias ExShop.Order

  test "list all orders" do
    conn = get conn, admin_order_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing Orders"
  end

  test "show order details" do
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

end
