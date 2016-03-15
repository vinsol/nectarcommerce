defmodule Nectar.Admin.SettingControllerTest do
  use Nectar.ConnCase

  alias Nectar.User
  alias Nectar.Repo
  alias Nectar.ShippingMethod
  alias Nectar.PaymentMethod

  setup(context) do
    do_setup(context)
  end

  test "list payment method settings", %{conn: conn} do
    setup_payments
    assert Repo.all(PaymentMethod.enabled_payment_methods) == []
    setting_page_conn = get(conn, admin_setting_path(conn, :payment_method_settings))
    assert html_response(setting_page_conn, 200) =~ "cheque"
  end

  test "list shipping method settings", %{conn: conn} do
    setup_shippings
    assert Repo.all(ShippingMethod.enabled_shipping_methods) == []
    setting_page_conn = get(conn, admin_setting_path(conn, :shipping_method_settings))
    assert html_response(setting_page_conn, 200) =~ "regular"
  end

  defp setup_payments do
    shipping_methods = ["cheque", "cash"]
    shipping_method_ids = Enum.map(shipping_methods, fn(method_name) ->
      PaymentMethod.changeset(%PaymentMethod{}, %{name: method_name})
      |> Repo.insert!
    end)
  end

  defp setup_shippings do
    shipping_methods = ["regular", "express"]
    shipping_method_ids = Enum.map(shipping_methods, fn(method_name) ->
      Nectar.ShippingMethod.changeset(%Nectar.ShippingMethod{}, %{name: method_name})
      |> Nectar.Repo.insert!
    end)
  end

  defp do_setup(_context) do
    admin = Repo.insert!(%User{name: "Admin", email: "admin@vinsol.com", encrypted_password: Comeonin.Bcrypt.hashpwsalt("vinsol"), is_admin: true})
    conn = guardian_login(admin, :token, key: :admin)
    {:ok, %{conn: conn}}
  end

end
