defmodule Nectar.VariantOptionValue do
  use Nectar.Web, :model

  schema "variant_option_values" do
    field :option_type_id, :integer

    belongs_to :variant, Nectar.Variant
    belongs_to :option_value, Nectar.OptionValue

    timestamps()
    extensions()
  end

  @required_fields ~w(variant_id option_value_id)a
  @optional_fields ~w()a

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  @required_fields ~w(option_value_id option_type_id)a
  @optional_fields ~w()a
  def from_variant_changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> remove_if_not_in_valid_product_option_type
  end

  def remove_if_not_in_valid_product_option_type(changeset) do
    if changeset.data.id do
      variant = Nectar.Repo.get_by(Nectar.Variant, id: changeset.data.variant_id)
                              |> Nectar.Repo.preload(product: :product_option_types)
      product_option_types = variant.product.product_option_types
      available_product_option_type_ids = Enum.map(product_option_types, &(&1.option_type_id))
      if Enum.any?(available_product_option_type_ids, &(&1 == changeset.data.option_type_id)) do
        changeset
      else
        %{changeset | action: :delete}
      end
    else
      changeset
    end
  end
end
