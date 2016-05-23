defmodule Nectar.TestSetup.Variant do
  import Ecto

  alias Nectar.TestSetup
  alias Nectar.Repo
  alias Nectar.OptionType
  alias Nectar.Product
  alias Nectar.Variant


  @variant_attrs %{
    cost_price: "30",
    discontinue_on: Ecto.Date.utc,
    height: "2", weight: "2", width: "2",
    sku: "URG123"
  }

  defp get_valid_variant_params(option_type) do
    option_values = option_type.option_values
    first_option_value = Enum.at(option_values, 0)
    valid_variant_option_value_attrs = %{
      variant_option_values: [
        %{
          option_type_id: option_type.id,
          option_value_id: first_option_value.id
        }
      ]
    }
    valid_variant_with_option_value_attrs = Map.merge(@variant_attrs, valid_variant_option_value_attrs)
    valid_variant_with_option_value_attrs
  end

  def create_variant do
    option_type = TestSetup.OptionType.create_option_type
    product = TestSetup.Product.create_product_with_option_type(TestSetup.Product.default_product_attrs, option_type)
    valid_variant_with_option_value_attrs = get_valid_variant_params(option_type)

    variant =
      product
      |> build_assoc(:variants)
      |> Variant.create_variant_changeset(valid_variant_with_option_value_attrs)
      |> Repo.insert!

    %{product: product, variant: variant, option_type: option_type}
  end

  def add_quantity(variant, quantity) do
    variant
    |> Nectar.Variant.changeset(%{add_count: 3})
    |> Repo.update!
  end

  # defp example_setup do
  #   option_type = create_option_type
  #   assert option_type.id

  #   ## Need to import Product test-setup module
  #   ## Changed here as create_product_with
  #   product = create_product
  #   assert product.id

  #   product = Product.update_changeset(product, %{
  #       product_option_types: [
  #         %{option_type_id: option_type.id}
  #       ]
  #     })
  #     |> Repo.update!

  #   assert product.product_option_types

  #   last_option_value = Enum.at(option_type.option_values, 1)
  #   assert last_option_value

  #   changeset = product
  #     |> build_assoc(:variants)
  #     |> Variant.create_variant_changeset(
  #       Map.merge(@variant_attrs, %{
  #         variant_option_values: [
  #           %{
  #             option_type_id: option_type.id,
  #             option_value_id: last_option_value.id
  #           }
  #         ]
  #       })
  #     )

  #   assert changeset.valid?
  # end
end
