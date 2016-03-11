defmodule ExShop.Admin.CartController do
  use ExShop.Web, :admin_controller

  plug Guardian.Plug.EnsureAuthenticated, handler: ExShop.Auth.HandleAdminUnauthenticated, key: :admin

  alias ExShop.Order
  alias ExShop.Repo
  alias ExShop.LineItem
  alias ExShop.Product

  import Ecto.Query


  def new(conn, _params) do
    users = ExShop.Repo.all(ExShop.User)
    cart_changeset = ExShop.Order.cart_changeset(%ExShop.Order{}, %{})
    render(conn, "new.html", users: users, cart_changeset: cart_changeset)
  end

  # use guest checkout unless user id provided.
  def create(conn, %{"order" => %{"user_id" => ""}}) do
    order = ExShop.Order.cart_changeset(%ExShop.Order{}, %{}) |> Repo.insert!
    conn
    |> redirect(to: admin_cart_path(conn, :edit, order))
  end

  def create(conn, %{"order" => %{"user_id" => user_id}}) do
    order = ExShop.Order.user_cart_changeset(%ExShop.Order{}, %{user_id: user_id}) |> Repo.insert!
    conn
    |> redirect(to: admin_cart_path(conn, :edit, order))
  end


  def edit(conn, %{"id" => id}) do
    {:ok, order} = Repo.get!(ExShop.Order, id) |> ExShop.CheckoutManager.back("cart")
    products  =
      Product
      |> Repo.all
      |> Repo.preload([variants: [option_values: :option_type]])

    line_items =
      LineItem
      |> LineItem.in_order(order)
      |> Repo.all
      |> Repo.preload([variant: [:product, [option_values: :option_type]]])

    render(conn, "edit.html", order: order, products: products, line_items: line_items)
  end

end
