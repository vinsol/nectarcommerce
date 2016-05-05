defmodule ExtensionsManager.ExtendProduct do
  use ExtensionsManager.ModelExtension
  use FavoriteProducts.NectarExtension, install: "products"
end

defmodule ExtensionsManager.ExtendUser do
  use ExtensionsManager.ModelExtension
  use FavoriteProducts.NectarExtension, install: "users"
end

defmodule ExtensionsManager.Router do
  use ExtensionsManager.RouterExtension
  use FavoriteProducts.NectarExtension, install: "router"
end
