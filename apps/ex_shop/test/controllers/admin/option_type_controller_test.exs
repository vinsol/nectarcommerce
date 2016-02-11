defmodule ExShop.Admin.OptionTypeControllerTest do
  use ExShop.ConnCase

  alias ExShop.OptionType
  @valid_attrs %{name: "some content", position: 42, presentation: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, admin_option_type_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing option types"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, admin_option_type_path(conn, :new)
    assert html_response(conn, 200) =~ "New option type"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, admin_option_type_path(conn, :create), option_type: @valid_attrs
    assert redirected_to(conn) == admin_option_type_path(conn, :index)
    assert Repo.get_by(OptionType, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, admin_option_type_path(conn, :create), option_type: @invalid_attrs
    assert html_response(conn, 200) =~ "New option type"
  end

  test "shows chosen resource", %{conn: conn} do
    option_type = Repo.insert! %OptionType{}
    conn = get conn, admin_option_type_path(conn, :show, option_type)
    assert html_response(conn, 200) =~ "Show option type"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, admin_option_type_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    option_type = Repo.insert! %OptionType{}
    conn = get conn, admin_option_type_path(conn, :edit, option_type)
    assert html_response(conn, 200) =~ "Edit option type"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    option_type = Repo.insert! %OptionType{}
    conn = put conn, admin_option_type_path(conn, :update, option_type), option_type: @valid_attrs
    assert redirected_to(conn) == admin_option_type_path(conn, :show, option_type)
    assert Repo.get_by(OptionType, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    option_type = Repo.insert! %OptionType{}
    conn = put conn, admin_option_type_path(conn, :update, option_type), option_type: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit option type"
  end

  test "deletes chosen resource", %{conn: conn} do
    option_type = Repo.insert! %OptionType{}
    conn = delete conn, admin_option_type_path(conn, :delete, option_type)
    assert redirected_to(conn) == admin_option_type_path(conn, :index)
    refute Repo.get(OptionType, option_type.id)
  end
end
