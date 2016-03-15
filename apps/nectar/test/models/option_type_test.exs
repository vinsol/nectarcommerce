defmodule Nectar.OptionTypeTest do
  use Nectar.ModelCase

  alias Nectar.OptionType

  @valid_attrs %{name: "some content", position: 42, presentation: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = OptionType.changeset(%OptionType{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = OptionType.changeset(%OptionType{}, @invalid_attrs)
    refute changeset.valid?
  end
end
