defmodule Nectar.LineItemReturnTest do
  use Nectar.ModelCase

  alias Nectar.Repo
  alias Nectar.Order
  alias Nectar.LineItemReturn
  alias Nectar.LineItem

  @valid_attrs %{quantity: 42, status: 42, line_item_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = LineItemReturn.changeset(%LineItemReturn{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = LineItemReturn.changeset(%LineItemReturn{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "return accepted" do
    assert Repo.all(Order) == []

    {:ok, line_item: line_item} = Nectar.TestSetup.Order.create_order_with_line_items

    refute Repo.all(Order) == []
    [order] = Repo.all(Order)

    order = order |> Repo.preload([:line_items])

    assert Enum.count(order.line_items) == 1

    assert order.state == "confirmation"
    assert order.confirmation_status

    line_item =  line_item |> Repo.preload(:variant)
    old_variant = line_item.variant
    IO.inspect old_variant
    IO.inspect old_variant.bought_quantity

    {_status, line_item} = LineItem.cancel_fullfillment(%LineItem{line_item|order: order})
    refute line_item.fullfilled

    line_item_return = Nectar.Repo.one(from lr in Nectar.LineItemReturn, where: lr.line_item_id == ^line_item.id )
    Nectar.LineItemReturn.accept_or_reject(line_item_return, %{"status" => 1})

    updated_line_item = Repo.get(LineItem, line_item.id) |> Repo.preload(:variant)
    IO.inspect updated_line_item.variant
    assert updated_line_item.variant.bought_quantity == old_variant.bought_quantity - updated_line_item.quantity
  end

  test "return discarded" do

  end
end
