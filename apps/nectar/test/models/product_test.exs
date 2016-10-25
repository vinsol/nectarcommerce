defmodule Nectar.ProductTest do
  use Nectar.ModelCase

  alias Nectar.Repo
  alias Nectar.Product

  import Nectar.DateTestHelpers, only: [get_past_date: 0, get_future_date: 1]
  import Nectar.TestSetup.Product, only: [create_product: 0, valid_attrs_with_option_type: 0, invalid_attrs: 0]

  describe "fields" do
    fields = ~w(id name description available_on discontinue_on slug)a ++ timestamps
    has_fields Product, fields
  end

  describe "associations" do
    assocs = ~w(master variants product_option_types option_types product_categories categories)a
    has_associations Product, assocs

    has_one?  Product, :master, via: Nectar.Variant
    has_many? Product, :variants, via: Nectar.Variant

    has_many? Product, :product_option_types, via: Nectar.ProductOptionType
    has_many? Product, :option_types, through: [:product_option_types, :option_type]

    has_many? Product, :product_categories, via: Nectar.ProductCategory
    has_many? Product, :categories, through: [:product_categories, :category]
  end

  describe "validations" do
    test "changeset with valid attributes" do
      changeset = Product.changeset(%Product{}, valid_attrs_with_option_type)
      assert errors_on(changeset) == []
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = Product.changeset(%Product{}, invalid_attrs)
      refute changeset.valid?
    end

    test "Discontinue on should not be past date and greater than product available_on" do
      product = create_product
      master_variant = Nectar.Query.Product.master_variant(Repo, product)

      changeset = Product.update_changeset(product, %{"master" => %{"discontinue_on" => get_past_date, "id" => master_variant.id}})

      assert errors_on(changeset.changes.master) == [discontinue_on: "should be greater or same as #{Ecto.Date.utc}", discontinue_on: "can not be past date"]
    end

    test "Available on should be less than Master Variant discontinue_on" do
      product = create_product
      master_variant = Nectar.Query.Product.master_variant(Repo, product)
      params = %{"master" => %{"discontinue_on" => get_future_date(5), "id" => master_variant.id}}
      product =
        Product.update_changeset(product, params)
        |> Repo.update!

      master_variant = Nectar.Query.Product.master_variant(Repo, product)

      assert master_variant.discontinue_on == get_future_date(5)

      changeset = Product.update_changeset(product, %{"available_on" => get_future_date(7)})
      assert errors_on(changeset) == [available_on: "should be less or same as #{get_future_date(5)}"]

      changeset = Product.update_changeset(product, %{
            "available_on" => get_future_date(7),
            "master" => %{
              "discontinue_on" => get_future_date(6), "id" => master_variant.id
            }
                                           })
      assert errors_on(changeset) == [available_on: "should be less or same as #{get_future_date(6)}"]
    end
  end

end
