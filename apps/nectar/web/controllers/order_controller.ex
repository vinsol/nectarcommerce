defmodule Nectar.OrderController do
  use Nectar.Web, :controller
  use Guardian.Phoenix.Controller

  alias Nectar.Order

  plug Guardian.Plug.EnsureAuthenticated, handler: Nectar.Auth.HandleUnauthenticated

  def index(conn, _params, current_user, _claims) do
    # Show only confirmed orders
    orders = Repo.all(
      from o in Order,
        join: u in assoc(o, :user),
        where: o.user_id == u.id and o.state == "confirmation" and u.id == ^current_user.id
    )
    render(conn, "index.html", orders: orders)
  end

  def show(conn, %{"id" => id}, current_user, _claims) do
    order = Repo.one(
      from o in Order,
        join: u in assoc(o, :user),
        where: (
          o.user_id == u.id and
          o.state == "confirmation" and
          u.id == ^current_user.id and
          o.id == ^id
        )
    )
    if order do
      order = order
              |> Repo.preload([line_items: [variant: [:product, [option_values: :option_type]]]])
              |> Repo.preload([shipments: [:shipping_method, :adjustment, shipment_unit: [line_items: [variant: [:product, [option_values: :option_type]]]]]])
              |> Repo.preload([adjustments: [:tax, :shipment]])
              |> Repo.preload([payment: [:payment_method]])
      render(conn, "show.html", order: order)
    else
      conn
        |> put_flash(:info, "Order Not found with id #{id}")
        |> redirect(to: admin_order_path(conn, :index))
        |> halt()
    end
  end
end
