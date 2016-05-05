defmodule FavoriteProducts.UserTest do
  use FavoriteProducts.ModelCase

  alias Nectar.User

  test "added associations to Nectar.User successfully" do
    assert Enum.member?(Nectar.User.__schema__(:associations), :likes)
    assert Enum.member?(Nectar.User.__schema__(:associations), :liked_products)
  end

  test "added methods to Nectar.User" do
    assert Enum.member?(Nectar.User.__info__(:functions), {:liked_products, 1})
  end
end
