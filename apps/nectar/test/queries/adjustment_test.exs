defmodule Nectar.Query.AdjustmentTest do
  use Nectar.ModelCase

  alias Nectar.Query

  describe "for_order/2" do
    test "returns all adjustments for order" do
      order = Nectar.TestSetup.Order.setup_cart
      assert Query.Adjustment.for_order(Nectar.Repo, order) == []
    end
  end

end
