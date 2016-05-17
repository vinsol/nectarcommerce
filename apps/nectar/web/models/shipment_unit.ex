defmodule Nectar.ShipmentUnit do
  use Nectar.Web, :model
  alias __MODULE__
  alias Nectar.Repo
  alias Nectar.LineItem

  schema "shipment_units" do

    # associations
    belongs_to  :shipping_method, Nectar.ShippingMethod
    has_many :line_items, Nectar.LineItem

    # virtual fields
    field :proposed_shipping_methods, {:array, :map}, virtual: true

    timestamps
    extensions
  end

  @required_fields ~w()
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(), ~w())
  end

  def create(line_items) do
    Repo.transaction(fn ->
      shipment_unit = Repo.insert!(changeset(%ShipmentUnit{}, %{}))
      query = LineItem.set_shipment_unit(Enum.map(line_items, &(&1.id)), shipment_unit.id)
      Repo.update_all(query, [])
      shipment_unit |> Repo.preload([:line_items])
    end)
  end

  def shipment_method_changeset(model, params \\ :empty) do

  end

end
