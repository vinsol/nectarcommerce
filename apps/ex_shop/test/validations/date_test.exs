defmodule Validations.DateTest do
  use ExShop.ModelCase

  alias ExShop.Product
  import ExShop.DateTestHelpers

  @tag :validate_gt_ref_date
  test "Add Error if past date" do
    changeset = Product.changeset(%Product{}, %{available_on: get_past_date})
      |> Validations.Date.validate_gt_date(:available_on, get_current_date, message: "should be future date")
    assert Keyword.get(changeset.errors, :available_on) == "should be future date"
  end

  @tag :validate_gt_ref_date
  test "No Error if current date" do
    changeset = Product.changeset(%Product{}, %{available_on: get_current_date})
      |> Validations.Date.validate_gt_date(:available_on, get_current_date, message: "should be future date")
    refute Keyword.get(changeset.errors, :available_on)
  end

  @tag :validate_gt_ref_date
  test "No Error if future date" do
    changeset = Product.changeset(%Product{}, %{available_on: get_future_date})
      |> Validations.Date.validate_gt_date(:available_on, get_current_date, message: "should be future date")
    refute Keyword.get(changeset.errors, :available_on)
  end

  @tag :validate_lt_ref_date
  test "Add Error if ref_date less than changed value" do
    changeset = Product.changeset(%Product{}, %{available_on: Ecto.Date.utc})
      |> Validations.Date.validate_lt_date(:available_on, get_past_date, message: "should be less than REF_DATE")
    assert Keyword.get(changeset.errors, :available_on) == "should be less than REF_DATE"
  end

  @tag :validate_lt_ref_date
  test "No Error if ref_date equal to changed value" do
    changeset = Product.changeset(%Product{}, %{available_on: Ecto.Date.utc})
      |> Validations.Date.validate_lt_date(:available_on, Ecto.Date.utc, message: "should be less than REF_DATE")
    refute Keyword.get(changeset.errors, :available_on)
  end

  @tag :validate_lt_ref_date
  test "No Error if ref_date greater than changed date" do
    changeset = Product.changeset(%Product{}, %{available_on: Ecto.Date.utc})
      |> Validations.Date.validate_lt_date(:available_on, get_future_date, message: "should be less than REF_DATE")
    refute Keyword.get(changeset.errors, :available_on)
  end
end
