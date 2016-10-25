defmodule  Nectar.SettingPair do
  use Nectar.Web, :model

  embedded_schema do
    field :name
    field :value
  end

  @required_fields ~w(name)a
  @optional_fields ~w(value)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

end
