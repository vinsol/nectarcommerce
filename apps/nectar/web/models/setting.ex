defmodule Nectar.Setting do
  use Nectar.Web, :model

  schema "settings" do
    field :name, :string
    field :slug, :string
    embeds_many :settings, Nectar.SettingPair
    extensions
  end

  @required_fields ~w(name)a
  @optional_fields ~w(slug)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> generate_slug()
    |> cast_embed(:settings)
  end

  defp generate_slug(changeset) do
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

defimpl Phoenix.Param, for: Nectar.Setting do
  def to_param(%{slug: slug}) do
    slug
  end
end
