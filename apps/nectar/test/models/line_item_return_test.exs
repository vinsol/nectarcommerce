defmodule Nectar.LineItemReturnTest do
  use Nectar.ModelCase

  alias Nectar.LineItemReturn

  @valid_attrs %{quantity: 42, status: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = LineItemReturn.changeset(%LineItemReturn{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = LineItemReturn.changeset(%LineItemReturn{}, @invalid_attrs)
    refute changeset.valid?
  end
end
