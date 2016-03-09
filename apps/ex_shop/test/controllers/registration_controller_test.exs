defmodule ExShop.RegistrationControllerTest do
  use ExShop.ConnCase

  alias ExShop.User

  @valid_attrs %{email: "test@vinsol.com", password: "vinsol", password_confirmation: "vinsol"}
  @invalid_attrs %{}

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, registration_path(conn, :new)
    assert html_response(conn, 200) =~ "New registration"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, registration_path(conn, :create), registration: @valid_attrs
    assert redirected_to(conn) == page_path(conn, :index)
    assert Repo.get_by(User, email: @valid_attrs.email)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, registration_path(conn, :create), registration: @invalid_attrs
    assert html_response(conn, 200) =~ "New registration"
  end
end
