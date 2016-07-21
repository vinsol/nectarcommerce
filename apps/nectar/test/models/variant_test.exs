defmodule Nectar.VariantTest do
  use Nectar.ModelCase

  alias Nectar.Variant

  import Nectar.DateTestHelpers, only: [get_past_date: 0]
  import Nectar.TestSetup.Product, only: [create_product: 0]

  @variant_attrs %{
    cost_currency: "INR", cost_price: "30", weight: 3, height: 3, width: 3, depth: 3,
    discontinue_on: Ecto.Date.utc, sku: "SKU 123"
  }
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    product =
      create_product
      |> Nectar.Repo.preload([product_option_types:
                             [option_type: :option_values]])

    [product_option_type] = product.product_option_types
    option_type = product_option_type.option_type
    last_option_value = Enum.at(option_type.option_values, 1)
    assert last_option_value

    changeset = product
      |> build_assoc(:variants)
      |> Variant.create_variant_changeset(
        product,
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
    product =
      create_product
      |> Nectar.Repo.preload([product_option_types:
                             [option_type: :option_values]])

    [product_option_type] = product.product_option_types
    option_type = product_option_type.option_type
    last_option_value = Enum.at(option_type.option_values, 1)

    changeset = product
      |> build_assoc(:variants)
      |> Variant.create_variant_changeset(
        product,
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
    product =
      create_product
      |> Nectar.Repo.preload([product_option_types:
                             [option_type: :option_values]])

    [product_option_type] = product.product_option_types
    option_type = product_option_type.option_type
    last_option_value = Enum.at(option_type.option_values, 1)

    changeset = product
      |> build_assoc(:variants)
      |> Variant.create_variant_changeset(
        product,
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

    assert errors_on(changeset) == [discontinue_on: "should be greater or same as #{Ecto.Date.utc}", discontinue_on: "can not be past date"]
  end

  test "Update: Discontinue on should not be past date and greater than product available_on" do
    variant = Nectar.TestSetup.Variant.create_variant |> Nectar.Repo.preload([:product])
    changeset = Variant.update_variant_changeset(variant, variant.product, %{"discontinue_on" => get_past_date})
    assert errors_on(changeset) == [discontinue_on: "should be greater or same as #{Ecto.Date.utc}", discontinue_on: "can not be past date"]
  end
end
