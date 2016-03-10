defmodule ExShop.TestSetup.Product do
  alias ExShop.Repo
  alias ExShop.Product

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

  def create_product do
    product_changeset = Product.create_changeset(%Product{}, @valid_product_attrs)
    product = Repo.insert! product_changeset
    product |> Repo.preload([:product_option_types, :product_categories])
  end
end
