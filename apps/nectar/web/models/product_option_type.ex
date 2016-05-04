defmodule Nectar.ProductOptionType do
  use Nectar.Web, :model

  schema "product_option_types" do
    field :delete, :boolean, virtual: true

    belongs_to :product, Nectar.Product
    belongs_to :option_type, Nectar.OptionType

    timestamps
    extensions
  end

  @required_fields ~w(product_id option_type_id)
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

  def from_product_changeset(model, params \\ :empty) do
    cast(model, params, ~w(option_type_id), ~w(delete))
    |> set_delete_action
    |> unique_constraint(:option_type_id, name: :unique_product_option_types_index)
  end

  def set_delete_action(changeset) do
    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end
end
