defmodule Nectar.Query.CategoryTest do
  use Nectar.ModelCase
  alias Nectar.Query
  alias Nectar.Repo

  describe "leaf_categories/1" do
    test "sanity" do
      assert Query.Category.leaf_categories(Repo) == []
    end
  end

  describe "with_associated_products/1" do
    test "sanity" do
      assert Query.Category.with_associated_products(Repo) == []
    end
  end
end
