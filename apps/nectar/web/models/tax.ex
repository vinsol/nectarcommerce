defmodule Nectar.Tax do
  use Nectar.Web, :model

  schema "taxes" do
    field :name

    timestamps
    extensions
  end

  @optional_fields ~w()a
  @required_fields ~w(name)a

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

end
