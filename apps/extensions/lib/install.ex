defmodule ExtendProduct do
  use Extensions.ModelExtension
  # can be further inferred from __CALLER__ in case we go with
  # a further set of conventions
  # essentially reducing it to
  # use FavoriteProducts
  use FavoriteProductsPhoenix.NectarExtension, install: "products"
end

defmodule ExtendUser do
  use Extensions.ModelExtension
  use FavoriteProductsPhoenix.NectarExtension, install: "users"
end


defmodule ExtendUserLike do
  use Extensions.ModelExtension
  include_method do
    def can_extend_an_extension? do
      true
    end
  end
end

defmodule ExtensionsRouter do
  use Extensions.RouterExtension

  use FavoriteProductsPhoenix.NectarExtension, install: "router"
end
