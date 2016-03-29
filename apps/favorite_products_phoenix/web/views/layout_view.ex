defmodule FavoriteProductsPhoenix.LayoutView do
  use Nectar.Web, :view
  # import FavoriteProductsPhoenix.Router.Helpers

  defdelegate render(conn, view), to: Nectar.LayoutView

end
