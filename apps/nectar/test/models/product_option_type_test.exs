defmodule Nectar.ProductOptionTypeTest do
  use Nectar.ModelCase

  alias Nectar.ProductOptionType

  @valid_attrs %{product_id: 1, option_type_id: 1}
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
