defmodule Nectar.Admin.CartController do
  use Nectar.Web, :admin_controller

  alias Nectar.Repo
  alias Nectar.LineItem
  alias Nectar.Product

  def new(conn, _params) do
    users = Nectar.Repo.all(Nectar.User)
    cart_changeset = Nectar.Order.cart_changeset(%Nectar.Order{}, %{})
    render(conn, "new.html", users: users, cart_changeset: cart_changeset)
  end

  # use guest checkout unless user id provided.
  def create(conn, %{"order" => %{"user_id" => ""}}) do
    order = Nectar.Command.Order.create_empty_cart_for_guest!(Repo)
    conn
    |> redirect(to: admin_cart_path(conn, :edit, order))
  end

  def create(conn, %{"order" => %{"user_id" => user_id}}) do
    order = Nectar.Command.Order.create_empty_cart_for_user!(Repo, user_id)
    conn
    |> redirect(to: admin_cart_path(conn, :edit, order))
  end

  def edit(conn, %{"id" => id}) do
    {:ok, order} = Repo.get!(Nectar.Order, id) |> Nectar.CheckoutManager.back("cart")
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
