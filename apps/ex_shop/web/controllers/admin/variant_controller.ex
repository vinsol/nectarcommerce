defmodule ExShop.Admin.VariantController do
  use ExShop.Web, :admin_controller

  alias ExShop.Product
  alias ExShop.Variant
  alias ExShop.VariantOptionValue

  plug :scrub_params, "variant" when action in [:create, :update]
  plug :find_product
  plug :find_variant when action in [:show, :edit, :update]

  def index(conn, %{"product_id" => _product_id}) do
    product = conn.assigns[:product]
    variants = Repo.all(from v in Variant, where: v.product_id == ^product.id)
    render(conn, "index.html", variants: variants)
  end

  def new(conn, %{"product_id" => _product_id}) do
    product = conn.assigns[:product]
    variant_option_values = Enum.map(product.option_types, fn(o) -> %VariantOptionValue{} end)
    changeset = Variant.changeset(%Variant{variant_option_values: variant_option_values})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"variant" => variant_params, "product_id" => _product_id}) do
    product = conn.assigns[:product]
    changeset = product
      |> build_assoc(:variants)
      |> Variant.variant_changeset(variant_params)

    case Repo.insert(changeset) do
      {:ok, _variant} ->
        conn
        |> put_flash(:info, "Variant created successfully.")
        |> redirect(to: admin_product_variant_path(conn, :index, product))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id, "product_id" => _product_id}) do
    render(conn, "show.html")
  end

  def edit(conn, %{"id" => id, "product_id" => _product_id}) do
    variant = conn.assigns[:variant]
    changeset = Variant.changeset(variant)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"id" => id, "variant" => variant_params}) do
    product = conn.assigns[:product]
    variant = conn.assigns[:variant]
    changeset = Variant.variant_changeset(variant, variant_params)

    case Repo.update(changeset) do
      {:ok, variant} ->
        conn
        |> put_flash(:info, "Variant updated successfully.")
        |> redirect(to: admin_product_variant_path(conn, :show, product, variant))
      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    product = conn.assigns[:product]
    variant = conn.assigns[:variant]

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(variant)

    conn
    |> put_flash(:info, "Variant deleted successfully.")
    |> redirect(to: admin_product_variant_path(conn, :index, product))
  end

  defp find_product(conn, _) do
    product = Repo.get_by(Product, id: conn.params["product_id"])
      |> Repo.preload(option_types: :option_values)
    case product do
      nil ->
        conn
        |> put_flash(:info, "Product Not Found")
        |> redirect(to: admin_product_path(conn, :index))
        |> halt()
      _ ->
        conn
        |> assign(:product, product)
    end
  end

  defp find_variant(conn, _) do
    product = conn.assigns[:product]
    variant = Repo.get_by(Variant, id: conn.params["id"], product_id: product.id) |> Repo.preload([:product, :variant_option_values, option_values: :option_type])
    case variant do
      nil ->
        conn
        |> put_flash(:info, "Variant Not Found")
        |> redirect(to: admin_product_variant_path(conn, :index, product))
        |> halt()
      _ ->
        conn
        |> assign(:variant, variant)
    end
  end
end
