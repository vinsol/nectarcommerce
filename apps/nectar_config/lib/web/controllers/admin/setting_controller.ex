defmodule Nectar.Admin.SettingController do
  use NectarCore.Web, :admin_controller

  plug Guardian.Plug.EnsureAuthenticated, handler: Nectar.Auth.HandleAdminUnauthenticated, key: :admin

  alias Nectar.Setting

  def edit(conn, %{"id" => slug}) do
    setting  = Repo.get_by!(Nectar.Setting, slug: slug)
    changeset = Setting.changeset(setting)
    render(conn, "edit.html", setting: setting, changeset: changeset)
  end

  def update(conn, %{"id" => slug, "setting" => setting_params}) do
    setting = Repo.get_by!(Nectar.Setting, slug: slug)
    changeset = Setting.changeset(setting, setting_params)
    case Repo.update(changeset) do
      {:ok, setting} ->
        conn
        |> put_flash(:info, "Setting updated successfully.")
        |> render("edit.html", setting: setting, changeset: changeset)
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Something went wrong. Please try again.")
        |> render("edit.html", setting: setting, changeset: changeset)
    end
  end

  def shipping_method_settings(conn, _params) do
    shipping_methods = Repo.all(Nectar.ShippingMethod)
    render(conn, "shipping.html", shipping_methods: shipping_methods)
  end

  def update_shipping_method_settings(conn, %{"shipping_methods" => params}) do
    enabled_shipping_method_ids =
      Enum.filter(params, fn
        ({_, %{"enabled" => "true"}}) -> true
        ({_, %{"enabled" => "false"}}) -> false
      end) |> Enum.map(fn({_, %{"id" => id}}) -> id end)
    Repo.update_all(Nectar.ShippingMethod.enable(enabled_shipping_method_ids), [])
    Repo.update_all(Nectar.ShippingMethod.disable_other_than(enabled_shipping_method_ids), [])
    conn
    |> put_flash(:info, "Updated Shipping methods succesfully")
    |> redirect(to: NectarRoutes.admin_setting_path(conn, :shipping_method_settings))
  end

  def payment_method_settings(conn, _params) do
    payment_methods = Repo.all(from p in Nectar.PaymentMethod, order_by: p.id)
    render(conn, "payment.html", payment_methods: payment_methods)
  end

  def update_payment_method_settings(conn, %{"payment_methods" => params}) do
    enabled_payment_method_ids =
      Enum.filter(params, fn
        ({_, %{"enabled" => "true"}}) -> true
        ({_, %{"enabled" => "false"}}) -> false
      end) |> Enum.map(fn({_, %{"id" => id}}) -> id end)
    Repo.update_all(Nectar.PaymentMethod.enable(enabled_payment_method_ids), [])
    Repo.update_all(Nectar.PaymentMethod.disable_other_than(enabled_payment_method_ids), [])
    conn
    |> put_flash(:info, "Updated Payment methods succesfully")
    |> redirect(to: NectarRoutes.admin_setting_path(conn, :payment_method_settings))
  end

end
