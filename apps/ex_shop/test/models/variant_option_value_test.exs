defmodule ExShop.VariantOptionValueTest do
  use ExShop.ModelCase

  alias ExShop.VariantOptionValue

  @valid_attrs %{variant_id: 1, option_value_id: 1, option_type_id: 1}
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
