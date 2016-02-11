defmodule ExShop.OptionValue do
  use ExShop.Web, :model

  schema "option_values" do
    field :name, :string
    field :presentation, :string
    field :position, :integer
    field :delete, :boolean, virtual: true

    belongs_to :option_type, ExShop.OptionType

    timestamps
  end

  @required_fields ~w(name presentation)
  @optional_fields ~w(delete)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:name, name: :option_values_name_option_type_index)
    |> set_delete_action
  end

  def set_delete_action(changeset) do
    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end
end
