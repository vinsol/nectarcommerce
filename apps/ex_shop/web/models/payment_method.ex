defmodule ExShop.PaymentMethod do

  use ExShop.Web, :model

  schema "payment_methods" do
    field :name, :string
    has_many :payments, ExShop.Payment
  end


  @required_fields ~w(name)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end


end
