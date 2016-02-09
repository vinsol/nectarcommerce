defmodule ExShop.OptionType do
  use ExShop.Web, :model

  schema "option_types" do
    field :name, :string
    field :presentation, :string
    field :position, :integer

    timestamps
  end

  @required_fields ~w(name presentation position)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:name)
  end
end
