defmodule ExShop.VariantOptionValueTest do
  use ExShop.ModelCase

  alias ExShop.VariantOptionValue

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = VariantOptionValue.changeset(%VariantOptionValue{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = VariantOptionValue.changeset(%VariantOptionValue{}, @invalid_attrs)
    refute changeset.valid?
  end
end
