defmodule Seed.LoadProducts do
  alias ExShop.Product
  alias ExShop.Repo
  alias ExShop.OptionType
  alias ExShop.Variant

  def seed! do
    seed_products_without_variant
    seed_products_with_variant
  end

  @product_data %{name: "Sample Product",
                  description: "Sample Product for testing without variant",
                  available_on: Ecto.Date.utc,
                  master: %{cost_price: 20.00, add_count: 10}}

  defp seed_products_without_variant do
    # create the product
    data = @product_data
    Product.create_changeset(%Product{}, data)
    |> Repo.insert!
  end

  @product_data %{name: "Sample Product 2",
                  description: "Sample Product for testing with 3 variants(One Master + 3 Other)",
                  available_on: Ecto.Date.utc,master: %{cost_price: 10.00, add_count: 10}}
  @not_discontinue_date  Ecto.Date.cast!("2017-03-01")
  @discontinue_date  Ecto.Date.utc
  @variant_one_data %{discontinue_on: @not_discontinue_date, cost_price: 20.00, sku: "Variant 1"}
  @variant_two_data %{discontinue_on: @not_discontinue_date, cost_price: 22.00, sku: "Variant 2", add_count: 11}
  @variant_three_data %{discontinue_on: @discontinue_date, cost_price: 22.00, sku: "Discontinued Example", add_count: 11}
  defp seed_products_with_variant do
    option_type = seed_option_type_and_values
    data = Map.merge(@product_data, %{product_option_types: [%{option_type_id: option_type.id}]})
    product  = Product.create_changeset(%Product{}, data) |> Repo.insert!
    variant_1_data = Map.merge(@variant_one_data,
                               %{variant_option_values: [
                                    %{option_type_id: option_type.id,
                                      option_value_id: List.first(option_type.option_values).id}
                                  ]
                                })
    variant_2_data = Map.merge(@variant_two_data,
                               %{variant_option_values: [
                                    %{option_type_id: option_type.id,
                                      option_value_id: List.last(option_type.option_values).id}
                                  ]
                                })

    variant_3_data = Map.merge(@variant_three_data,
                               %{variant_option_values: [
                                    %{option_type_id: option_type.id,
                                      option_value_id: List.last(option_type.option_values).id}
                                  ]
                                })


    product
    |> Ecto.build_assoc(:variants)
    |> Variant.create_variant_changeset(variant_1_data)
    |> Repo.insert!

    product
    |> Ecto.build_assoc(:variants)
    |> Variant.create_variant_changeset(variant_2_data)
    |> Repo.insert!

    product
    |> Ecto.build_assoc(:variants)
    |> Variant.create_variant_changeset(variant_3_data)
    |> Repo.insert!
  end

  @option_value_1 %{name: "Large", presentation: "L"}
  @option_value_2 %{name: "Small", presentation: "S"}
  @option_type    %{name: "Size", presentation: "Size", option_values: [@option_value_1, @option_value_2]}
  defp seed_option_type_and_values do
    OptionType.changeset(%OptionType{}, @option_type)
    |> Repo.insert!
  end
end
