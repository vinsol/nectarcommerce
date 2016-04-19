defmodule Nectar.Admin.CartView do
  use NectarCore.Web, :view

  # This will depend on preload ??
  # We should actually look at whether product has product option types
  # This can lead to incorrect variant additions in corrupted data
  # We might have to disallow such products in listing and addition too
  def only_master_variant?(%Nectar.Product{variants: [], master: _master}), do: true
  def only_master_variant?(%Nectar.Product{variants: [_]}), do: true
  def only_master_variant?(%Nectar.Product{variants: [_|_]}), do: false

  def out_of_stock?(%Nectar.Variant{} = variant), do: Nectar.Variant.available_quantity(variant) == 0

  def product_variant_options(%Nectar.Product{} = product) do
    Enum.map(product.variants, fn
      (%Nectar.Variant{is_master: true}) -> "" # Do not add master variant to product list
      (variant) ->
        content_tag(:option, value: variant.id, disabled: out_of_stock?(variant)) do
          Nectar.Admin.VariantView.variant_options_text(variant)
          <> if out_of_stock?(variant) do
            "(Out of stock)"
          else
            ""
          end
        end
    end)
  end

  def master_variant_id(%Nectar.Product{variants: [master_variant]}), do: master_variant.id

end
