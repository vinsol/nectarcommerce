defmodule ExShop.Slug do
  import Ecto.Changeset, only: [get_change: 2, put_change: 3]

  def generate_slug(changeset) do
    # TODO: Take care of case when slug is given directly
    if name = get_change(changeset, :name) do
      put_change(changeset, :slug, slugify(name))
    else
      changeset
    end
  end

  defp slugify(str) do
    str
    |> String.downcase()
    |> String.replace(~r/[^\w-]+/, "-")
  end
end
