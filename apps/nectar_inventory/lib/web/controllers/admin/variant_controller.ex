defmodule Nectar.Admin.VariantController do
  use NectarCore.Web, :admin_controller

  alias Nectar.Product
  alias Nectar.Variant
  alias Nectar.VariantOptionValue

  plug Guardian.Plug.EnsureAuthenticated, handler: Nectar.Auth.HandleAdminUnauthenticated, key: :admin
  plug :scrub_params, "variant" when action in [:create, :update]
  plug :find_product
  plug :restrict_action when action in [:new, :create]
  plug :find_variant when action in [:show]
  plug :find_non_master_variant when action in [:delete, :edit, :update]

  def index(conn, %{"product_id" => _product_id}) do
    product = conn.assigns[:product]
    variants = Repo.all(from v in Variant, where: v.product_id == ^product.id)
      |> Repo.preload(option_values: :option_type)
    render(conn, "index.html", variants: variants)
  end

  def new(conn, %{"product_id" => _product_id}) do
    product = conn.assigns[:product]
    variant_option_values = Enum.map(product.option_types, fn(o) -> %VariantOptionValue{option_type_id: o.id} end)
    changeset = Variant.changeset(%Variant{discontinue_on: Ecto.Date.utc, variant_option_values: variant_option_values})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"variant" => variant_params, "product_id" => _product_id}) do
    product = conn.assigns[:product]
    changeset = product
      |> build_assoc(:variants)
      |> Variant.create_variant_changeset(variant_params)

    case Repo.insert(changeset) do
      {:ok, _variant} ->
        conn
        |> put_flash(:info, "Variant created successfully.")
        |> redirect(to: NectarRoutes.admin_product_variant_path(conn, :index, product))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => _id, "product_id" => _product_id}) do
    render(conn, "show.html")
  end

  def edit(conn, %{"id" => _id, "product_id" => _product_id}) do
    product = conn.assigns[:product]
    variant = conn.assigns[:variant]
    new_params = inspect_missing_option_values(product, variant)
    changeset = Variant.update_variant_changeset(variant, new_params)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"id" => _id, "variant" => variant_params}) do
    product = conn.assigns[:product]
    variant = conn.assigns[:variant]
    changeset = Variant.update_variant_changeset(variant, variant_params)

    case Repo.update(changeset) do
      {:ok, variant} ->
        conn
        |> put_flash(:info, "Variant updated successfully.")
        |> redirect(to: NectarRoutes.admin_product_variant_path(conn, :show, product, variant))
      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => _id}) do
    product = conn.assigns[:product]
    variant = conn.assigns[:variant]

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(variant)

    conn
    |> put_flash(:info, "Variant deleted successfully.")
    |> redirect(to: NectarRoutes.admin_product_variant_path(conn, :index, product))
  end

  defp find_product(conn, _) do
    product = Repo.get_by(Product, id: conn.params["product_id"])
      |> Repo.preload(option_types: :option_values)
    case product do
      nil ->
        conn
        |> put_flash(:info, "Product Not Found")
        |> redirect(to: NectarRoutes.admin_product_path(conn, :index))
        |> halt()
      _ ->
        conn
        |> assign(:product, product)
    end
  end

  defp find_variant(conn, _) do
    product = conn.assigns[:product]
    variant = Repo.get_by(Variant, id: conn.params["id"], product_id: product.id)
    case variant do
      nil ->
        conn
        |> put_flash(:info, "Variant Not Found")
        |> redirect(to: NectarRoutes.admin_product_variant_path(conn, :index, product))
        |> halt()
      _ ->
        # Preload here as when variant is nil
        # throws FunctionClauseError :(
        variant = variant |> Repo.preload([:product, :variant_option_values, option_values: :option_type])
        conn
        |> assign(:variant, variant)
    end
  end

  defp find_non_master_variant(conn, _) do
    product = conn.assigns[:product]
    variant = Repo.get_by(Variant, id: conn.params["id"], product_id: product.id, is_master: false)
    case variant do
      nil ->
        conn
        |> put_flash(:info, "Variant Not Found or is Master Variant")
        |> redirect(to: NectarRoutes.admin_product_variant_path(conn, :index, product))
        |> halt()
      _ ->
        # Preload here as when variant is nil
        # throws FunctionClauseError :(
        variant = variant |> Repo.preload([:product, :variant_option_values, option_values: :option_type])
        conn
        |> assign(:variant, variant)
    end
  end

  defp restrict_action(conn, _) do
    product = conn.assigns[:product]
    case product.option_types do
      [] ->
        conn
        |> put_flash(:info, "No Variants Allowed as Product Optin Type Not Present")
        |> redirect(to: NectarRoutes.admin_product_variant_path(conn, :index, product))
        |> halt()
      _ ->
        conn
    end
  end

  defp inspect_missing_option_values(product, variant) do
    if variant.is_master do
      %{}
    else
      available_product_option_type_ids = Enum.map(product.product_option_types, &(&1.option_type_id))
      available_variant_option_value_ids = Enum.map(variant.option_values, &(&1.option_type_id))
      missing_variant_option_value_ids = available_product_option_type_ids -- available_variant_option_value_ids
      missing_variant_option_value_params = Enum.map(missing_variant_option_value_ids, fn(m) ->
        %{"option_type_id" => m}
      end)
      if missing_variant_option_value_params != [] do
        %{"variant_option_values" => missing_variant_option_value_params}
      else
        %{}
      end
    end
  end
end
