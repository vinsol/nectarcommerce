defmodule Nectar.OptionTypeTest do
  use Nectar.ModelCase

  alias Nectar.OptionType

  describe "validations" do
    test "changeset with valid attributes" do
      changeset = OptionType.changeset(%OptionType{}, Nectar.TestSetup.OptionType.valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = OptionType.changeset(%OptionType{}, Nectar.TestSetup.OptionType.invalid_attrs)
      refute changeset.valid?
    end
  end

  describe "fields" do
    has_fields OptionType, ~w(id name presentation position)a ++ timestamps
  end

  describe "associations" do
    has_associations OptionType, ~w(option_values)a
  end
end
