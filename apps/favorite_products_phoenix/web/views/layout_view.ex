defmodule FavoriteProductsPhoenix.LayoutView do
  use Nectar.Web, :view
  # import FavoriteProductsPhoenix.Router.Helpers

  defdelegate render(template, assigns), to: Nectar.LayoutView

end
