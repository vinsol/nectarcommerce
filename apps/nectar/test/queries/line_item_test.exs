defmodule Nectar.Query.LineItemTest do
  use Nectar.ModelCase

  alias Nectar.TestSetup
  alias Nectar.Repo

  describe "in_order" do
    test "sanity" do
      line_item = TestSetup.LineItem.create
      order = Nectar.Query.Order.get!(Repo, line_item.order_id)
      assert Nectar.Query.LineItem.in_order(Repo, order) == [line_item]
    end
  end

  describe "with_variant" do
    test "sanity" do
      line_item = TestSetup.LineItem.create
      variant = Nectar.Query.Variant.get!(Nectar.Repo, line_item.variant_id)
      assert Nectar.Query.LineItem.with_variant(Repo, variant) == [line_item]
    end
  end

  describe "in_order_with_variant" do
    test "sanity" do
      line_item = TestSetup.LineItem.create
      variant = Nectar.Query.Variant.get!(Nectar.Repo, line_item.variant_id)
      order = Nectar.Query.Order.get!(Repo, line_item.order_id)
      assert Nectar.Query.LineItem.in_order_with_variant(Repo, order, variant) == line_item
    end
  end

end
