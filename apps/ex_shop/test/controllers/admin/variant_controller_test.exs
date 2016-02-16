defmodule ExShop.Admin.VariantControllerTest do
  use ExShop.ConnCase

  alias ExShop.Admin.Variant
  @valid_attrs %{cost_price: "120.5", discontinue_on: "2010-04-17", height: "120.5", image: "some content", sku: "some content", weight: "120.5", width: "120.5"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, variant_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing variants"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, variant_path(conn, :new)
    assert html_response(conn, 200) =~ "New variant"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, variant_path(conn, :create), variant: @valid_attrs
    assert redirected_to(conn) == variant_path(conn, :index)
    assert Repo.get_by(Variant, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, variant_path(conn, :create), variant: @invalid_attrs
    assert html_response(conn, 200) =~ "New variant"
  end

  test "shows chosen resource", %{conn: conn} do
    variant = Repo.insert! %Variant{}
    conn = get conn, variant_path(conn, :show, variant)
    assert html_response(conn, 200) =~ "Show variant"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, variant_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    variant = Repo.insert! %Variant{}
    conn = get conn, variant_path(conn, :edit, variant)
    assert html_response(conn, 200) =~ "Edit variant"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    variant = Repo.insert! %Variant{}
    conn = put conn, variant_path(conn, :update, variant), variant: @valid_attrs
    assert redirected_to(conn) == variant_path(conn, :show, variant)
    assert Repo.get_by(Variant, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    variant = Repo.insert! %Variant{}
    conn = put conn, variant_path(conn, :update, variant), variant: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit variant"
  end

  test "deletes chosen resource", %{conn: conn} do
    variant = Repo.insert! %Variant{}
    conn = delete conn, variant_path(conn, :delete, variant)
    assert redirected_to(conn) == variant_path(conn, :index)
    refute Repo.get(Variant, variant.id)
  end
end
