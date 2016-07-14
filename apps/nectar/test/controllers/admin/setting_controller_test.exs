defmodule Nectar.Admin.SettingControllerTest do
  use Nectar.ConnCase

  setup(context) do
    do_setup(context)
  end

  test "list payment method settings", %{conn: conn} do
    Nectar.TestSetup.PaymentMethod.create_payment_methods
    setting_page_conn = get(conn, admin_setting_path(conn, :payment_method_settings))
    assert html_response(setting_page_conn, 200) =~ "cheque"
  end

  test "list shipping method settings", %{conn: conn} do
    Nectar.TestSetup.ShippingMethod.create_shipping_methods
    setting_page_conn = get(conn, admin_setting_path(conn, :shipping_method_settings))
    assert html_response(setting_page_conn, 200) =~ "regular"
  end

  defp do_setup(_context) do
    {:ok, admin} = Nectar.TestSetup.User.create_admin
    conn = guardian_login(admin)
    {:ok, %{conn: conn}}
  end

end
