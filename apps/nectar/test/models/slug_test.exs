defmodule ExSHop.SlugTest do
  use Nectar.ModelCase

  alias Nectar.Product
  alias Nectar.Slug

  @valid_product_attrs %{available_on: "2010-04-17 14:00:00", description: "some content", discontinue_on: "2010-04-17 14:00:00", name: "slug ed"}

  test "slug not given and not already present and slug base field present" do
    changeset = Product.changeset(%Product{}, %{name: "123"})
      |> Slug.generate_slug
    assert changeset.changes == %{name: "123", slug: "123"}
  end

  test "slug not given but already present" do
    existing_product = Product.changeset(%Product{}, @valid_product_attrs)
      |> Slug.generate_slug
      |> Repo.insert!

    assert existing_product.slug == "slug-ed"

    changeset = Product.changeset(existing_product, %{name: "234"})
      |> Slug.generate_slug
    assert changeset.changes == %{name: "234"}
  end

  test "slug given and not already present & slug base not present" do
    changeset = Product.changeset(%Product{}, %{slug: "123"})
      |> Slug.generate_slug
    assert changeset.changes == %{slug: "123"}
  end

  test "slug given and not already present & slug base present" do
    changeset = Product.changeset(%Product{}, %{name: "234", slug: "123"})
      |> Slug.generate_slug
    assert changeset.changes == %{name: "234", slug: "123"}
  end

  test "slug given but already present" do
    existing_product = Product.changeset(%Product{}, @valid_product_attrs)
      |> Slug.generate_slug
      |> Repo.insert!

    assert existing_product.slug == "slug-ed"

    changeset = Product.changeset(existing_product, %{slug: "234"})
      |> Slug.generate_slug
    assert changeset.changes == %{slug: "234"}
  end

  test "slug given but already present & slug base present" do
    existing_product = Product.changeset(%Product{}, @valid_product_attrs)
      |> Slug.generate_slug
      |> Repo.insert!

    assert existing_product.slug == "slug-ed"

    changeset = Product.changeset(existing_product, %{name: "123", slug: "234"})
      |> Slug.generate_slug
    assert changeset.changes == %{name: "123", slug: "234"}
  end
end
