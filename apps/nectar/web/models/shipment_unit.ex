defmodule Nectar.ShipmentUnit do
  use Nectar.Web, :model
  alias __MODULE__
  alias Nectar.Repo
  alias Nectar.LineItem

  schema "shipment_units" do

    # associations

    belongs_to  :order, Nectar.Order

    has_many :line_items, Nectar.LineItem, on_delete: :nilify_all
    has_one  :shipment, Nectar.Shipment, on_delete: :nilify_all

    # virtual fields
    field :proposed_shipments, {:array, :map}, virtual: true

    timestamps
    extensions
  end

  @required_fields ~w(order_id)a
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
  end

  def create(line_items) do
    order_id = List.first(line_items) |> Map.get(:order_id)
    {:ok, shipment_unit} = Repo.transaction(fn ->
      shipment_unit = Repo.insert!(changeset(%ShipmentUnit{}, %{order_id: order_id}))
      query = LineItem.set_shipment_unit(Enum.map(line_items, &(&1.id)), shipment_unit.id)
      Repo.update_all(query, [])
      shipment_unit |> Repo.preload([:line_items])
    end)
    shipment_unit
  end

  @required_fields ~w()a
  @optional_fields ~w()a
  def create_shipment_changeset(model, params \\ %{}) do
    model
    |> cast(params_with_shipping_cost(model, params), @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> cast_assoc(:shipment, required: true, with: &Nectar.Shipment.create_changeset/2)
  end

  defp params_with_shipping_cost(model, %{"shipment" => %{"shipping_method_id" => ""}} = params), do: params
  defp params_with_shipping_cost(model, %{"shipment" => %{"shipping_method_id" => shipping_method_id}} = params) do
    shipping_method = Nectar.Repo.get(Nectar.ShippingMethod, shipping_method_id)
    {:ok, shipping_cost} = Nectar.ShippingCalculator.shipping_cost(shipping_method, model)

    %{params | "shipment" => Map.merge(Map.get(params, "shipment"), %{"shipping_cost" => shipping_cost, "order_id" => model.order_id})}
  end
  defp params_with_shipping_cost(model, params), do: params
  defp add_shipping_cost_to(params), do: params

end
