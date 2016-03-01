defmodule ExShop.Admin.VariantControllerTest do
  use ExShop.ConnCase

  alias ExShop.Repo
  alias ExShop.User
  alias ExShop.OptionType
  alias ExShop.Product
  alias ExShop.Variant

  @product_attrs %{
    name: "Reebok Premium",
    description: "Reebok Premium Exclusively for you",
    available_on: "2010-04-17 14:00:00"
  }
  @master_variant_attrs %{
    master: %{
      cost_price: "20"
    }
  }
  @option_type_attrs %{
    name: "Color", # Can lead to intermittent issues failing unique validation
    presentation: "Color",
    option_values: [
      %{
        name: "Red",
        presentation: "Red"
      },
      %{
        name: "Green",
        presentation: "Green"
      }
    ]
  }
  @valid_product_attrs Map.merge(@product_attrs, @master_variant_attrs)

  @variant_option_value_attrs %{
    variant_option_values: [
      %{
        option_value_id: "1",
        option_type_id: "1"
      }
    ]
  }
  @valid_attrs %{
    cost_price: "120.5",
    discontinue_on: %{"year" => "2016", "month" => "2", "day" => "1"},
    height: "120.5", weight: "120.5", width: "120.5",
    sku: "URG123"
  }
  @invalid_attrs %{}

  setup(context) do
    do_setup(context)
  end

  @tag nologin: true
  test "should redirect if not logged in", %{conn: conn, product: product} do
    conn = get conn, admin_product_variant_path(conn, :index, product)
    assert html_response(conn, 302)
  end

  test "lists all entries on index", %{conn: conn, product: product} do
    conn = get conn, admin_product_variant_path(conn, :index, product)
    assert html_response(conn, 200) =~ "Listing variants"
  end

  @tag :no_product_option_types
  test "redirects to listing when no ProductOptionTypes present", %{conn: conn, product: product} do
    conn = get conn, admin_product_variant_path(conn, :new, product)
    assert html_response(conn, 302)
    assert get_flash(conn, :info) =~ "No Variants Allowed"
  end

  test "renders form for new resources", %{conn: conn, product: product} do
    assert product.product_option_types != []
    conn = get conn, admin_product_variant_path(conn, :new, product)
    assert html_response(conn, 200) =~ "New variant"
  end

  test "creates resource and redirects when data is valid", (%{conn: conn, product: product} = data) do
    {_, %{valid_variant_with_option_value_attrs: valid_variant_with_option_value_attrs}} = get_valid_variant_params(data)
    conn = post conn, admin_product_variant_path(conn, :create, product), variant: valid_variant_with_option_value_attrs
    assert redirected_to(conn) == admin_product_variant_path(conn, :index, product)
    assert Repo.get_by(Variant, Map.merge(@valid_attrs, %{is_master: false, product_id: product.id}))
  end

  @tag :pending
  test "creates resource and redirects when data is valid and has image", (%{conn: _conn, product: _product} = _data) do
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn, product: product} do
    conn = post conn, admin_product_variant_path(conn, :create, product), variant: @invalid_attrs
    assert html_response(conn, 200) =~ "New variant"
  end

  test "shows chosen resource", (%{conn: conn, product: product} = data) do
    {_, %{variant: variant}} = create_variant(data)
    conn = get conn, admin_product_variant_path(conn, :show, product, variant)
    assert html_response(conn, 200) =~ "Show variant"
  end

  test "renders page not found when id is nonexistent", %{conn: conn, product: product} do
    conn = get conn, admin_product_variant_path(conn, :show, product, -1)
    assert redirected_to(conn) == admin_product_variant_path(conn, :index, product)
  end

  test "renders form for editing chosen resource", (%{conn: conn, product: product} = data) do
    {_, %{variant: variant}} = create_variant(data)
    conn = get conn, admin_product_variant_path(conn, :edit, product, variant)
    assert html_response(conn, 200) =~ "Edit variant"
  end

  @tag :master_variant
  test "editing for master variant is not allowed and should take to variants index page instead", (%{conn: conn, product: product} = _data) do
    master_variant = Repo.get_by(Variant, %{is_master: true, product_id: product.id})
    conn = get conn, admin_product_variant_path(conn, :edit, product, master_variant)
    assert redirected_to(conn) == admin_product_variant_path(conn, :index, product)
  end

  test "updates chosen resource and redirects when data is valid", (%{conn: conn, product: product} = data) do
    {_, %{variant: variant}} = create_variant(data)
    conn = put conn, admin_product_variant_path(conn, :update, product, variant), variant: @valid_attrs
    assert redirected_to(conn) == admin_product_variant_path(conn, :show, product, variant)
    assert Repo.get_by(Variant, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", (%{conn: conn, product: product} = data) do
    {_, %{variant: variant}} = create_variant(data)
    conn = put conn, admin_product_variant_path(conn, :update, product, variant), variant: %{"cost_price" => ""}
    assert html_response(conn, 200) =~ "Edit variant"
  end

  test "deletes chosen resource", (%{conn: conn, product: product} = data) do
    {_, %{variant: variant}} = create_variant(data)
    conn = delete conn, admin_product_variant_path(conn, :delete, product, variant)
    assert redirected_to(conn) == admin_product_variant_path(conn, :index, product)
    refute Repo.get(Variant, variant.id)
  end

  @tag :master_variant
  test "restrict deletion of master variant", (%{conn: conn, product: product} = _data) do
    master_variant = Repo.get_by(Variant, %{is_master: true, product_id: product.id})
    conn = delete conn, admin_product_variant_path(conn, :delete, product, master_variant)
    assert redirected_to(conn) == admin_product_variant_path(conn, :index, product)
    assert Repo.get(Variant, master_variant.id)
  end

  defp do_setup(%{nologin: _} = _context) do
    product_changeset = Product.create_changeset(%Product{}, @valid_product_attrs)
    product = Repo.insert! product_changeset
    {:ok, %{conn: conn, product: product}}
  end

  defp do_setup(%{no_product_option_types: _} = _context) do
    product_changeset = Product.create_changeset(%Product{}, @valid_product_attrs)
    product = Repo.insert! product_changeset
    admin_user = Repo.insert!(%User{name: "Admin", email: "admin@vinsol.com", encrypted_password: Comeonin.Bcrypt.hashpwsalt("vinsol"), is_admin: true})
    conn = guardian_login(admin_user, :token, key: :admin)
    {:ok, %{conn: conn, product: product}}
  end

  defp do_setup(_context) do
    option_type_changeset = OptionType.changeset(%OptionType{}, @option_type_attrs)
    option_type = Repo.insert!(option_type_changeset) |> Repo.preload([:option_values])
    product_option_type_attrs = %{
      product_option_types: [
        %{
          option_type_id: option_type.id
        }
      ]
    }
    valid_product_with_option_type_attrs = Map.merge(@valid_product_attrs, product_option_type_attrs)
    product_changeset = Product.create_changeset(%Product{}, valid_product_with_option_type_attrs)
    product = Repo.insert! product_changeset
    admin_user = Repo.insert!(%User{name: "Admin", email: "admin@vinsol.com", encrypted_password: Comeonin.Bcrypt.hashpwsalt("vinsol"), is_admin: true})
    conn = guardian_login(admin_user, :token, key: :admin)
    {:ok, %{conn: conn, product: product, option_type: option_type}}
  end

  defp get_valid_variant_params(data) do
    option_type = data.option_type
    option_values = option_type.option_values
    first_option_value = Enum.at(option_values, 1)
    valid_variant_option_value_attrs = %{
      variant_option_values: [
        %{
          option_type_id: option_type.id,
          option_value_id: first_option_value.id
        }
      ]
    }
    valid_variant_with_option_value_attrs = Map.merge(@valid_attrs, valid_variant_option_value_attrs)
    {:ok, %{valid_variant_with_option_value_attrs: valid_variant_with_option_value_attrs}}
  end

  defp create_variant(data) do
    {_, %{valid_variant_with_option_value_attrs: valid_variant_with_option_value_attrs}} = get_valid_variant_params(data)
    product = data.product
    variant_changeset = product |> build_assoc(:variants) |> Variant.create_variant_changeset(valid_variant_with_option_value_attrs)
    assert variant_changeset.valid?
    variant = Repo.insert! variant_changeset
    {:ok, %{variant: variant}}
  end
end
