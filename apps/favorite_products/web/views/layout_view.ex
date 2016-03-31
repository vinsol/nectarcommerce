defmodule FavoriteProducts.LayoutView do
  use FavoriteProducts.Web, :view
  defdelegate render(template, assigns), to: Nectar.LayoutView
end
