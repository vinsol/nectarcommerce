defmodule Nectar.Command.Product do
  use Nectar.Command, model: Nectar.Product
  alias Nectar.Product

  def insert!(repo, params) do
    Product.create_changeset(%Product{}, params)
    |> repo.insert!
  end

  def update!(repo, existing, params) do
    Product.update_changeset(existing, params)
    |> repo.update!
  end

  def insert(repo, params) do
    Product.create_changeset(%Product{}, params)
    |> repo.insert
  end

  def update(repo, existing, params) do
    Product.update_changeset(existing, params)
    |> repo.update
  end

end
