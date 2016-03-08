defmodule ExShop.Admin.LayoutView do
  use ExShop.Web, :view

  def active_on_current(%{request_path: path}, path), do: "active"
  def active_on_current(_, _), do: nil

  def active_product_tab(conn) do
    active_on_current(conn, admin_option_type_path(conn, :index)) ||
    active_on_current(conn, admin_product_path(conn, :index))
  end

  def active_country_tab(conn) do
    active_on_current(conn, admin_country_path(conn, :index))
  end

  def active_zone_tab(conn) do
    active_on_current(conn, admin_zone_path(conn, :index)) ||
    active_on_current(conn, admin_zone_path(conn, :new))
  end

  def active_settings_tab(conn) do
    %{request_path: path} = conn
    if path == "/admin/settings/general/edit" do
      "active"
    else
      nil
    end
  end

  def active_orders_tab(conn) do
    active_on_current(conn, admin_order_path(conn, :index)) ||
    active_on_current(conn, admin_cart_path(conn, :new))
  end
end
