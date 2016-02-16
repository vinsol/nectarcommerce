defmodule ExShop.ProductOptionTypeTest do
  use ExShop.ModelCase

  alias ExShop.ProductOptionType

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = ProductOptionType.changeset(%ProductOptionType{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = ProductOptionType.changeset(%ProductOptionType{}, @invalid_attrs)
    refute changeset.valid?
  end
end
