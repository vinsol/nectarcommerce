defmodule Nectar.TaxTest do
  use Nectar.ModelCase, async: true
  alias Nectar.Tax

  describe "fields" do
    has_fields Tax, ~w(id name)a ++ timestamps
  end

  describe "associations" do
    has_associations Tax, ~w()a
  end

  describe "changeset/2" do
    test "with valid attributes" do
      assert Tax.changeset(%Tax{}, Nectar.TestSetup.Tax.valid_attrs).valid?
    end

    test "with invalid attributes" do
      refute Tax.changeset(%Tax{}, Nectar.TestSetup.Tax.invalid_attrs).valid?
    end
  end
end
