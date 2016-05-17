defmodule Nectar.RefundTest do
  use Nectar.ModelCase

  alias Nectar.Repo
  alias Nectar.Order
  alias Nectar.LineItemReturn
  alias Nectar.LineItem
  alias Nectar.Refund

  test "invalid changeset" do
    refund_changeset = Refund.create_changeset(%Refund{}, %{})
    assert Enum.uniq(Keyword.keys(refund_changeset.errors)) == [:line_item_return_id, :amount]
  end

  test "changeset errors" do
    assert Repo.all(Order) == []

    {:ok, line_item: line_item} = Nectar.TestSetup.Order.create_order_with_line_items

    refute Repo.all(Order) == []
    [order] = Repo.all(Order)

    order = order |> Repo.preload([:line_items])

    assert Enum.count(order.line_items) == 1

    assert order.state == "confirmation"
    assert order.confirmation_status

    ## Using line_item |> Repo.preload(:variant)
    ## gets copy from SQL cache, I assume and returns 0 instead of 2 :(
    line_item =  Repo.get(LineItem, line_item.id) |> Repo.preload(:variant)
    old_variant = line_item.variant

    {_status, line_item} = LineItem.cancel_fullfillment(%LineItem{line_item|order: order})
    refute line_item.fullfilled

    line_item_return = Repo.one(from lr in LineItemReturn, where: lr.line_item_id == ^line_item.id )
    {status, return} = LineItemReturn.accept_or_reject(line_item_return, %{"status" => 1})
    assert status == :ok
    assert return

    line_item_return = Repo.one(from lr in LineItemReturn, where: lr.line_item_id == ^line_item.id )
    assert line_item_return.status == 1

    refund_changeset = Refund.create_changeset(%Refund{}, %{"amount" => 2, "line_item_return_id" => line_item_return.id})
    assert refund_changeset.errors == []
  end
end
