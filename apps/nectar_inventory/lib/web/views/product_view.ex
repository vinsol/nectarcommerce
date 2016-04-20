defmodule Nectar.ProductView do
  use NectarCore.Web, :view

  alias Nectar.Product
  alias Nectar.Variant

  def only_master_variant?(%Product{variants: [], master: _master}), do: true
  def only_master_variant?(%Product{variants: [_]}), do: true
  def only_master_variant?(%Product{variants: [_|_]}), do: false

  def product_variant_options(%Product{} = product) do
    Enum.map(product.variants, fn(variant) ->
      {variant_name(variant), variant.id}
    end)
  end

  defp out_of_stock?(variant) do
    Variant.available_quantity(variant) == 0
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
