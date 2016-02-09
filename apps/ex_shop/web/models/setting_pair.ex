defmodule  ExShop.SettingPair do
  use Ecto.Model

  embedded_schema do
    field :name
    field :value
  end

  @required_fields ~w(name)
  @optional_fields ~w(value)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

end
