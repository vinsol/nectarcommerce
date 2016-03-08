defmodule ExShop.TestSetup.Variant do
  import Ecto

  alias ExShop.Repo
  alias ExShop.OptionType
  alias ExShop.Product
  alias ExShop.Variant

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

  @option_type_attrs %{
    name: "Color", # Can lead to intermittent issues failing unique validation
    presentation: "Color",
    option_values: [
      %{
        name: "Red",
        presentation: "Red"
      },
      %{
        name: "Green",
        presentation: "Green"
      }
    ]
  }

  @variant_option_value_attrs %{
    variant_option_values: [
      %{
        option_value_id: "1",
        option_type_id: "1"
      }
    ]
  }

  @variant_attrs %{
    cost_price: "30",
    discontinue_on: Ecto.Date.utc,
    height: "2", weight: "2", width: "2",
    sku: "URG123"
  }

  defp create_option_type do
    option_type_changeset = OptionType.changeset(%OptionType{}, @option_type_attrs)
    option_type = Repo.insert!(option_type_changeset)
      |> Repo.preload([:option_values])
  end

  def create_product_with(option_type) do
    product_option_type_attrs = %{
      product_option_types: [
        %{
          option_type_id: option_type.id
        }
      ]
    }
    valid_product_with_option_type_attrs = Map.merge(@valid_product_attrs, product_option_type_attrs)
    product = Product.create_changeset(%Product{}, valid_product_with_option_type_attrs)
      |> Repo.insert!
  end

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
    option_type = create_option_type
    product = create_product_with(option_type)

    valid_variant_with_option_value_attrs = get_valid_variant_params(option_type)

    variant = product
      |> build_assoc(:variants)
      |> Variant.create_variant_changeset(valid_variant_with_option_value_attrs)
      |> Repo.insert!

    %{product: product, variant: variant, option_type: option_type}
  end

  defp example_setup do
    option_type = create_option_type
    assert option_type.id

    ## Need to import Product test-setup module
    ## Changed here as create_product_with
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
end
