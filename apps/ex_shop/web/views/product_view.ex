defmodule ExShop.ProductView do
  use ExShop.Web, :view

  defdelegate only_master_variant?(product), to: ExShop.Admin.CartView

  def product_variant_options(%ExShop.Product{} = product) do
    Enum.map(product.variants, fn(variant) ->
      {variant_name(variant), variant.id}
    end)
  end

  defp out_of_stock?(variant) do
    ExShop.Variant.available_quantity(variant) == 0
  end

  defp variant_name(variant) do
    ExShop.Admin.VariantView.variant_options_text(variant)
    <> if out_of_stock?(variant) do
      " (out of stock)"
    else
      ""
    end
  end

end
