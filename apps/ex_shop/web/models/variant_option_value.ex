defmodule ExShop.VariantOptionValue do
  use ExShop.Web, :model

  schema "variant_option_values" do
    belongs_to :variant, ExShop.Variant
    belongs_to :option_value, ExShop.OptionValue

    timestamps
  end

  @required_fields ~w(variant_id option_value_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def from_variant_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(option_value_id), ~w())
  end
end
