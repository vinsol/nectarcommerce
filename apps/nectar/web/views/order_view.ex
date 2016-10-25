defmodule Nectar.OrderView do
  use Nectar.Web, :view

  alias Nectar.Admin.VariantView

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
