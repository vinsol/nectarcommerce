defmodule ExShop.Admin.CategoryTest do
  use ExShop.ModelCase

  alias ExShop.Admin.Category

  @valid_attrs %{lft: 42, name: "some content", parent_id: 42, rgt: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Category.changeset(%Category{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Category.changeset(%Category{}, @invalid_attrs)
    refute changeset.valid?
  end
end
