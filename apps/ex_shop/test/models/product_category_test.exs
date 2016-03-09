defmodule ExShop.ProductCategoryTest do
  use ExShop.ModelCase

  alias ExShop.ProductCategory

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = ProductCategory.changeset(%ProductCategory{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = ProductCategory.changeset(%ProductCategory{}, @invalid_attrs)
    refute changeset.valid?
  end
end
