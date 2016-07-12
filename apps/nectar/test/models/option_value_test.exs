defmodule Nectar.OptionValueTest do
  use Nectar.ModelCase
  alias Nectar.TestSetup
  alias Nectar.OptionValue

  describe "fields" do
    has_fields OptionValue, ~w(id name presentation position option_type_id)a ++ timestamps
  end

  describe "associations" do
    has_associations OptionValue, ~w(option_type)a
  end

  describe "validations" do
    test "changeset with valid attributes" do
      changeset = OptionValue.changeset(%OptionValue{}, TestSetup.OptionValue.valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = OptionValue.changeset(%OptionValue{}, TestSetup.OptionValue.invalid_attrs)
      refute changeset.valid?
    end
  end

end
