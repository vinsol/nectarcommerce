defmodule DeletedProductsTest do
  use ExUnit.Case

  test "added field to Nectar.Product succesfully" do
    assert Enum.member? Nectar.Product.__schema__(:fields), :deleted
  end

  test "added associations to Nectar.Product succesfully" do
    assert Enum.member? Nectar.Product.__schema__(:associations), :deleted_by
  end

  test "added methods to Nectar.Product succesfully" do
    assert Enum.member? Nectar.Product.__info__(:functions), {:mark_as_deleted_changeset, 2}
    assert Enum.member? Nectar.Product.__info__(:functions), {:deleted_products, 0}
  end
end
