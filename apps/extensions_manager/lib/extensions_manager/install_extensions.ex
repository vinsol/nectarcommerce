defmodule ExtensionsManager.ExtendProduct do
  use ExtensionsManager.ModelExtension
  use FavoriteProducts.NectarExtension, install: "products"
  use DeletedProducts, install: "products"
end

defmodule ExtensionsManager.ExtendUser do
  use ExtensionsManager.ModelExtension
  use FavoriteProducts.NectarExtension, install: "users"
  use NectarWallet.NectarExtension, install: "users"
end

defmodule ExtensionsManager.Router do
  use ExtensionsManager.RouterExtension
  use FavoriteProducts.NectarExtension, install: "router"
  use NectarWallet.NectarExtension, install: "router"
end

defmodule ExtensionsManager.ExtendCheckoutView do
  use ExtensionsManager.ViewExtension
  use NectarWallet.NectarExtension, install: "checkout_view"
end
