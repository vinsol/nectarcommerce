defmodule Nectar.OptionType do
  use Nectar.Web, :model

  schema "option_types" do
    field :name, :string
    field :presentation, :string
    field :position, :integer

    has_many :option_values, Nectar.OptionValue

    timestamps
    extensions
  end

  @required_fields ~w(name presentation)a
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
    |> cast_assoc(:option_values, required: true)
    |> unique_constraint(:name)
  end
end
