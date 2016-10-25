defmodule Nectar.CategoryTest do
  use Nectar.ModelCase

  alias Nectar.Category
  alias Nectar.TestSetup

  describe "fields" do
    has_fields Category, ~w(id name parent_id)a ++ timestamps
  end

  describe "associations" do
    has_associations Category, ~w(product_categories products children parent)a
  end

  describe "validations" do
    test "changeset with valid attributes" do
      changeset = Category.changeset(%Category{}, TestSetup.Category.valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = Category.changeset(%Category{}, TestSetup.Category.invalid_attrs)
      refute changeset.valid?
    end
  end
end
