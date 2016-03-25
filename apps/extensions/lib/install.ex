defmodule ExtendProduct do
  use Extension
  # can be further inferred from __CALLER__ in case we go with
  # a further set of conventions
  # essentially reducing it to
  # use FavoriteProducts
  use FavoriteProductsPhoenix.Install, install: "products"
end

defmodule ExtendUser do
  use Extension
  use FavoriteProductsPhoenix.Install, install: "users"
end
