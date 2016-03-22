defmodule ExtendProduct do
  use Extension
  require FavoriteProducts
  FavoriteProducts.install("products")
end

defmodule ExtendUser do
  use Extension
  require FavoriteProducts
  FavoriteProducts.install("users")
end
