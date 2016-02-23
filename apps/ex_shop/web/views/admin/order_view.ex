defmodule ExShop.Admin.OrderView do
  use ExShop.Web, :view

  def only_master_variant?(%ExShop.Product{variants: [_]}), do: true
  def only_master_variant?(%ExShop.Product{variants: [_|_]}), do: false

  def out_of_stock?(%ExShop.Variant{quantity: 0}), do: true
  def out_of_stock?(%ExShop.Variant{quantity: quantity}) when quantity > 0, do: false

  def product_variant_options(%ExShop.Product{} = product) do
    Enum.map(product.variants, fn (variant) ->
      content_tag(:option, value: variant.id, disabled: out_of_stock?(variant)) do
        # TODO maybe autogenerate sku if one is not provided
        variant.sku || product.name
      end
    end)
  end

  def master_variant_id(%ExShop.Product{variants: [master_variant]}), do: master_variant.id
end
