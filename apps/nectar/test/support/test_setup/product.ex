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

  def create_product(product_attrs \\ @valid_product_attrs) do
    product_changeset = Product.create_changeset(%Product{}, product_attrs)
    product = Repo.insert! product_changeset
    product |> Repo.preload([:product_option_types, :product_categories])
  end

  def create_product_with_master_variant_attrs(master_variant_attrs) do
    product_changeset = Product.create_changeset(%Product{}, Map.merge(@product_attrs, master_variant_attrs))
  end

  def create_products(count \\ 2) do
    Enum.map(1..count, fn (seq_no) ->
      prod_seq_name = "Product #{seq_no}"
      Map.update(@valid_product_attrs, :name, prod_seq_name, &(&1 <> Integer.to_string(seq_no)))
      |> create_product
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
