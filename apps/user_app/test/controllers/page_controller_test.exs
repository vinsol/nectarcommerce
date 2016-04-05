defmodule UserApp.PageControllerTest do
  use UserApp.ConnCase

  test "GET / returns nectar home page", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Hello Nectar"
  end
end
