defmodule ExShop.OptionValueTest do
  use ExShop.ModelCase

  alias ExShop.OptionValue

  @valid_attrs %{name: "some content", position: 42, presentation: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = OptionValue.changeset(%OptionValue{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = OptionValue.changeset(%OptionValue{}, @invalid_attrs)
    refute changeset.valid?
  end
end
