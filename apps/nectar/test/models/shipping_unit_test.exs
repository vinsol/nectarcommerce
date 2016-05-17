defmodule Nectar.ShippingUnitTest do
  use Nectar.ModelCase

  alias Nectar.ShippingUnit

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = ShippingUnit.changeset(%ShippingUnit{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = ShippingUnit.changeset(%ShippingUnit{}, @invalid_attrs)
    refute changeset.valid?
  end
end
