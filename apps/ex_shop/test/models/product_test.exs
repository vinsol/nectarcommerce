defmodule ExShop.ProductTest do
  use ExShop.ModelCase

  alias ExShop.Repo
  alias ExShop.Product

  import ExShop.DateTestHelpers


  @valid_attrs %{available_on: "2010-04-17 14:00:00", description: "some content", discontinue_on: "2010-04-17 14:00:00", name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Product.changeset(%Product{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Product.changeset(%Product{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "Discontinue on should not be past date and greater than product available_on" do
    product = create_product
    master_variant = Repo.one(Product.master_variant(product))

    changeset = Product.update_changeset(product, %{"master" => %{"discontinue_on" => get_past_date, "id" => master_variant.id}})
    assert changeset.changes.master.errors == [discontinue_on: "should be greater than #{Ecto.Date.utc}", discontinue_on: "can not be past date"]
  end

  test "Available on should be less than Master Variant discontinue_on" do
    product = create_product
    master_variant = Repo.one(Product.master_variant(product))

    product = Product.update_changeset(product, %{"master" => %{"discontinue_on" => get_future_date(5), "id" => master_variant.id}})
      |> Repo.update!

    master_variant = product
      |> Product.master_variant
      |> Repo.one

    assert master_variant.discontinue_on == get_future_date(5)

    changeset = Product.update_changeset(product, %{"available_on" => get_future_date(7)})
    assert changeset.errors == [available_on: "should be less than #{get_future_date(5)}"]

    changeset = Product.update_changeset(product, %{
      "available_on" => get_future_date(7),
      "master" => %{
        "discontinue_on" => get_future_date(6), "id" => master_variant.id
      }
    })
    assert changeset.errors == [available_on: "should be less than #{get_future_date(6)}"]
  end

  @product_attrs %{
    name: "Reebok Premium",
    description: "Reebok Premium Exclusively for you",
    available_on: Ecto.Date.utc
  }
  @master_variant_attrs %{
    master: %{
      cost_price: "20"
    }
  }
  @valid_product_attrs Map.merge(@product_attrs, @master_variant_attrs)

  defp create_product do
    product_changeset = Product.create_changeset(%Product{}, @valid_product_attrs)
    product = Repo.insert! product_changeset
    product |> Repo.preload(:product_option_types)
  end
end
