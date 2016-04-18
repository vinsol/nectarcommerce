defmodule Nectar.ProductView do
  use Nectar.Web, :view

  defdelegate only_master_variant?(product), to: Nectar.Admin.CartView

  def product_variant_options(%Nectar.Product{} = product) do
    Enum.map(product.variants, fn(variant) ->
      {variant_name(variant), variant.id}
    end)
  end

  defp out_of_stock?(variant) do
    Nectar.Variant.available_quantity(variant) == 0
  end

  defp variant_name(variant) do
    Nectar.Admin.VariantView.variant_options_text(variant)
    <> if out_of_stock?(variant) do
      " (out of stock)"
    else
      ""
    end
  end

end
