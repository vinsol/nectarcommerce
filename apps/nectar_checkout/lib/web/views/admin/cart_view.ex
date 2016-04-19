defmodule Nectar.Admin.CartView do
  use NectarCore.Web, :view

  alias Nectar.VariantForCheckout, as: Variant
  alias Nectar.ProductForCheckout, as: Product

  # This will depend on preload ??
  # We should actually look at whether product has product option types
  # This can lead to incorrect variant additions in corrupted data
  # We might have to disallow such products in listing and addition too
  def only_master_variant?(%Product{variants: [], master: _master}), do: true
  def only_master_variant?(%Product{variants: [_]}), do: true
  def only_master_variant?(%Product{variants: [_|_]}), do: false

  def out_of_stock?(%Variant{} = variant), do: Variant.available_quantity(variant) == 0

  def product_variant_options(%Product{} = product) do
    Enum.map(product.variants, fn
      (%Variant{is_master: true}) -> "" # Do not add master variant to product list
      (variant) ->
        content_tag(:option, value: variant.id, disabled: out_of_stock?(variant)) do
          Nectar.Admin.VariantView.variant_options_text(variant)
          <> out_of_stock_label(variant)
        end
    end)
  end

  def master_variant_id(%Product{variants: [master_variant]}), do: master_variant.id

  defp out_of_stock_label(variant) do
    if out_of_stock?(variant) do
      "(Out of stock)"
    else
      ""
    end
  end

end
