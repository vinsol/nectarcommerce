defmodule ExShop.VariantTest do
  use ExShop.ModelCase

  alias ExShop.Variant

  @valid_attrs %{cost_currency: "some content", cost_price: "120.5", depth: 42, discontinue_on: "2010-04-17 14:00:00", height: 42, is_master: true, sku: "some content", weight: 42, width: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Variant.changeset(%Variant{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Variant.changeset(%Variant{}, @invalid_attrs)
    refute changeset.valid?
  end
end
