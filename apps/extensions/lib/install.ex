defmodule ExtendProduct do
  use Extension
  # can be further inferred from __CALLER__ in case we go with
  # a further set of conventions
  # essentially reducing it to
  # use FavoriteProducts
  use FavoriteProductsPhoenix.NectarExtension, install: "products"
end

defmodule ExtendUser do
  use Extension
  use FavoriteProductsPhoenix.NectarExtension, install: "users"
end


defmodule ExtendUserLike do
  use Extension
  include_method do
    def can_extend_an_extension? do
      true
    end
  end
end
