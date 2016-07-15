defmodule Nectar.TestSetup.Product do
  alias Nectar.Repo
  alias Nectar.Product

  @product_attrs %{
    name: "Reebok Premium",
    description: "Reebok Premium Exclusively for you",
    available_on: Ecto.Date.utc
  }
  @master_variant_attrs %{
    master: %{
      cost_price: "20",
      add_count: 3
    }
  }
  @valid_product_attrs Map.merge(@product_attrs, @master_variant_attrs)

  def valid_attrs, do: @valid_product_attrs
  def invalid_attrs, do: %{}

  def valid_attrs_with_option_type do
    option_type = Nectar.TestSetup.OptionType.create_option_type
    product_option_type_params = %{product_option_types: [%{option_type_id: option_type.id}]}
    Map.merge(@valid_product_attrs, product_option_type_params)
  end

  def create_product(product_attrs \\ @valid_product_attrs) do
    option_type = Nectar.TestSetup.OptionType.create_option_type
    product_option_type_params = %{product_option_types: [%{option_type_id: option_type.id}]}
    product_changeset = Product.create_changeset(%Product{}, Map.merge(product_attrs, product_option_type_params))
    product = Repo.insert! product_changeset
    product |> Repo.preload([:product_option_types, :product_categories])
  end
  def create_product_with_oos_master do
    create_product_with_master_variant_attrs %{master: %{cost_price: "20"}}
  end

  def create_product_with_discontinued_master do
    import Nectar.DateTestHelpers, only: [get_past_date: 1]
    import Ecto.Query
    product = create_product_with_master_variant_attrs %{master: %{cost_price: "20", add_count: 2, discontinue_on: Ecto.Date.utc}}
    from(p in Product, where: p.id == ^product.id, update: [set: [available_on: ^get_past_date(3)]])
      |> Nectar.Repo.update_all([])
    from(v in Nectar.Variant, where: (v.product_id == ^product.id and v.is_master == true), update: [set: [discontinue_on: ^get_past_date(2)]])
      |> Nectar.Repo.update_all([])
    Nectar.Repo.get(Nectar.Product, product.id) |> Nectar.Repo.preload([:master])
  end

  def create_product_with_multiple_variants do
    product = create_product
    {:ok, variant} = Nectar.TestSetup.Variant.add_variant(product)
    %Nectar.Product{product|variants: [variant]}
  end

  def create_product_with_master_variant_attrs(master_variant_attrs) do
    create_product(Map.merge(@product_attrs, master_variant_attrs))
  end

  def create_products(count \\ 2) do
    option_type = Nectar.TestSetup.OptionType.create_option_type
    product_option_type_params = %{product_option_types: [%{option_type_id: option_type.id}]}

    Enum.map(1..count, fn (seq_no) ->
      prod_seq_name = "Product #{seq_no}"
      product_attrs = Map.update(@valid_product_attrs, :name, prod_seq_name, &(&1 <> Integer.to_string(seq_no)))
      product_changeset = Product.create_changeset(%Product{}, Map.merge(product_attrs, product_option_type_params))
      product = Repo.insert! product_changeset
      product |> Repo.preload([:product_option_types, :product_categories])
    end)
  end

  def create_product_with_option_type(product_attrs, option_type) do
    create_product(product_attrs)
    |> add_option_types(option_type)
  end

  def create_product_with(option_type) do
    create_product
    |> add_option_types(option_type)
  end

  def add_option_types(product, option_types) when is_list(option_types) do
    product_option_type_attrs = %{
      product_option_types: Enum.map(option_types, fn(option_type) -> %{option_type_id: option_type.id} end)
    }
    changeset = Product.update_changeset(product, product_option_type_attrs)
    changeset |> Repo.update!
  end

  def add_option_types(product, option_type) do
    add_option_types(product, [option_type])
  end

  def default_product_attrs do
    @valid_product_attrs
  end

end
