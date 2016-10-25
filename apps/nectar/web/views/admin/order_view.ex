defmodule Nectar.Admin.OrderView do
  use Nectar.Web, :view

  alias Nectar.Admin.VariantView

  def only_master_variant?(%Nectar.Product{variants: [_]}), do: true
  def only_master_variant?(%Nectar.Product{variants: [_|_]}), do: false

  def out_of_stock?(%Nectar.Variant{} = variant), do: Nectar.Variant.available_quantity(variant) == 0

  def product_variant_options(%Nectar.Product{} = product) do
    Enum.map(product.variants, fn
      (%Nectar.Variant{is_master: true}) -> "" # Do not add master variant to product list
      (variant) ->
        content_tag(:option, value: variant.id, disabled: out_of_stock?(variant)) do
        # TODO maybe autogenerate sku if one is not provided
          (VariantView.variant_options_text(variant))
          <> if out_of_stock?(variant) do
            "(Out of stock)"
          else
            ""
          end
        end
    end)
  end

  def master_variant_id(%Nectar.Product{variants: [master_variant]}), do: master_variant.id

  def shipment_items(shipment_unit) do
    Enum.reduce(shipment_unit.line_items, "", &("#{&2}" <> line_item_display_name(&1) <> ", "))
  end

  def line_item_display_name(line_item) do
    ## Assuming everything pre-loaded
    variant = line_item.variant
    product = variant.product
    product.name <> VariantView.variant_options_text(variant)
  end
end
