defmodule Nectar.Tax do
  use Nectar.Web, :model

  schema "taxes" do
    field :name

    timestamps
    extensions
  end

  @optional_fields ~w()
  @required_fields ~w(name)

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

end
