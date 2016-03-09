defmodule ExShop.User.ProductView do
  use ExShop.Web, :view

  defdelegate only_master_variant?(product), to: ExShop.Admin.CartView
  defdelegate product_variant_options(product), to: ExShop.Admin.CartView

end
