defmodule ExShop.ProductTest do
  use ExShop.ModelCase

  alias ExShop.Product

  @valid_attrs %{available_on: "2010-04-17 14:00:00", description: "some content", discontinue_on: "2010-04-17 14:00:00", name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Product.changeset(%Product{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Product.changeset(%Product{}, @invalid_attrs)
    refute changeset.valid?
  end
end
