defmodule Nectar.ShipmentTest do
  use Nectar.ModelCase

  alias Nectar.Shipment

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Shipment.changeset(%Shipment{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Shipment.changeset(%Shipment{}, @invalid_attrs)
    refute changeset.valid?
  end
end
