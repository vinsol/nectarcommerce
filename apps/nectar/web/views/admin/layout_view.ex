defmodule Nectar.Admin.LayoutView do
  use Nectar.Web, :view

  def active_on_current(%{request_path: path}, path), do: "active"
  def active_on_current(_, _), do: nil

  def active_product_tab(conn) do
    active_on_current(conn, admin_option_type_path(conn, :index)) ||
    active_on_current(conn, admin_category_path(conn, :index)) ||
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

  def js_view_name(view_module, view_template) do
    "Admin." <> view_module_name(view_module) <> "." <> view_template_name(view_template)
  end

  defp view_module_name(module_name) do
    module_name
    |> Phoenix.Naming.resource_name
    |> Phoenix.Naming.camelize
  end

  defp view_template_name(template_name) do
    String.replace_suffix(template_name, ".html", "")
  end

end
