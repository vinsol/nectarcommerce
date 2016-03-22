defmodule ExtendProduct do
  use Extension
  # can be further inferred from __CALLER__ in case we go with
  # a further set of conventions
  # essentially reducing it to
  # use FavoriteProducts
  use FavoriteProducts, install: "products"
end

defmodule ExtendUser do
  use Extension
  use FavoriteProducts, install: "users"
end
