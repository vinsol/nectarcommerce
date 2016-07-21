defmodule Nectar.CheckoutController do
  use Nectar.Web, :controller
  alias Nectar.CheckoutManager


  plug Guardian.Plug.EnsureAuthenticated, handler: __MODULE__
  plug :go_back_to_cart_if_empty when action in [:checkout, :next, :back]

  def checkout(conn, _params) do
    order = conn.assigns.current_order
    changeset = CheckoutManager.next_changeset(Repo, order)
    data = CheckoutManager.view_data(order)
    render(conn, "checkout.html", order: order, changeset: changeset, data: data)
  end

  def next(conn, %{"order" => order_params}) do
    order = conn.assigns.current_order
    case CheckoutManager.next(Repo, order, order_params) do
      {:error, updated_changeset} ->
        data = CheckoutManager.view_data(order)
        render(conn, "checkout.html", order: order, changeset: updated_changeset, data: data)
      {:ok, %Nectar.Order{state: "confirmation"} = updated_order} ->
        redirect(conn, to: order_path(conn, :show, updated_order))
      {:ok, updated_order} ->
        data = CheckoutManager.view_data(updated_order)
        render(conn, "checkout.html", order: updated_order, changeset: CheckoutManager.next_changeset(Repo, updated_order), data: data)
    end
  end

  def back(conn, _params) do
    order = conn.assigns.current_order
    case CheckoutManager.back(order) do
      {:ok, _updated_order} ->
        redirect(conn, to: checkout_path(conn, :checkout))
    end
  end

  # As its doing more than redirection
  # and handles unathenticated than general
  # so not using Common AuthModule for handling
  def unauthenticated(conn, _params) do
    conn
    |> put_flash(:error, "Please login before continuing checkout")
    |> put_session(:next_page, cart_path(conn, :show))
    |> redirect(to: session_path(conn, :new))
    |> halt
  end

  def go_back_to_cart_if_empty(conn, _params) do
    order = conn.assigns.current_order |> Repo.preload([:line_items])
    case order.line_items do
      [] -> conn |> redirect(to: cart_path(conn, :show)) |> halt
      _ -> conn
    end
  end

end
