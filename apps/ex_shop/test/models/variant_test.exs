defmodule ExShop.VariantTest do
  use ExShop.ModelCase

  alias ExShop.Product
  alias ExShop.Variant

  import ExShop.DateTestHelpers, only: [get_past_date: 0, get_current_date: 0, get_future_date: 1]
  import ExShop.TestSetup.Variant, only: [create_variant: 0, create_product_with: 1]

  import ExShop.TestSetup.OptionType, only: [create_option_type: 0]
  import ExShop.TestSetup.Product, only: [create_product: 0]

  @variant_attrs %{
    cost_currency: "INR", cost_price: "30", weight: 3, height: 3, width: 3, depth: 3,
    discontinue_on: Ecto.Date.utc, sku: "SKU 123"
  }
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    option_type = create_option_type
    assert option_type.id

    product = create_product
    assert product.id

    product = Product.update_changeset(product, %{
        product_option_types: [
          %{option_type_id: option_type.id}
        ]
      })
      |> Repo.update!

    assert product.product_option_types

    last_option_value = Enum.at(option_type.option_values, 1)
    assert last_option_value

    changeset = product
      |> build_assoc(:variants)
      |> Variant.create_variant_changeset(
        Map.merge(@variant_attrs, %{
          variant_option_values: [
            %{
              option_type_id: option_type.id,
              option_value_id: last_option_value.id
            }
          ]
        })
      )

    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    option_type = create_option_type
    assert option_type.id

    product = create_product_with(option_type)
    assert product.id
    assert product.product_option_types

    last_option_value = Enum.at(option_type.option_values, 1)
    assert last_option_value

    changeset = product
      |> build_assoc(:variants)
      |> Variant.create_variant_changeset(
        Map.merge(@invalid_attrs, %{
          variant_option_values: [
            %{
              option_type_id: option_type.id,
              option_value_id: last_option_value.id
            }
          ]
        })
      )

    refute changeset.valid?
  end

  test "Create: Discontinue on should not be past date and greater than product available_on" do
    option_type = create_option_type
    assert option_type.id

    product = create_product_with(option_type)
    assert product.id
    assert product.product_option_types

    last_option_value = Enum.at(option_type.option_values, 1)
    assert last_option_value

    changeset = product
      |> build_assoc(:variants)
      |> Variant.create_variant_changeset(
        Map.merge(@variant_attrs, %{
          variant_option_values: [
            %{
              option_type_id: option_type.id,
              option_value_id: last_option_value.id
            }
          ],
          discontinue_on: get_past_date
        })
      )

    assert changeset.errors == [discontinue_on: "should be greater or same as #{Ecto.Date.utc}", discontinue_on: "can not be past date"]
  end

  test "Update: Discontinue on should not be past date and greater than product available_on" do
    %{product: product, variant: variant, option_type: _option_type} = create_variant

    assert product.id
    assert variant.id

    changeset = Variant.update_variant_changeset(variant, %{"discontinue_on" => get_past_date})
    assert changeset.errors == [discontinue_on: "should be greater or same as #{Ecto.Date.utc}", discontinue_on: "can not be past date"]
  end
end
