defmodule Nectar.LineItem do
  use Nectar.Web, :model

  alias Nectar.Order
  alias Nectar.Variant
  alias Nectar.Product
  alias Nectar.Repo

  schema "line_items" do
    belongs_to :variant, Nectar.Variant
    belongs_to :order, Nectar.Order
    belongs_to :shipment_unit, Nectar.ShipmentUnit

    field :add_quantity, :integer, virtual: true, default: 0
    field :unit_price, :decimal
    field :quantity, :integer, default: 0
    field :total, :decimal
    field :fullfilled, :boolean, default: true

    field :delete, :boolean, virtual: true
    timestamps
    extensions
  end

  def changeset(model, params \\ %{}) do
    model
    |> create_changeset(params)
    |> quantity_changeset(params)
  end

  @required_fields ~w(fullfilled)a
  @optional_fields ~w()a
  def fullfillment_changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  @required_fields ~w(order_id unit_price)a
  @optional_fields ~w()a
  def create_changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:order_id)
  end

  @required_fields ~w(add_quantity unit_price)a
  @optional_fields ~w(fullfilled)a
  def quantity_changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_number(:add_quantity, greater_than: 0)
    |> add_to_existing_quantity
    |> quantity_update(params)
  end

  @required_fields ~w(quantity unit_price)a
  @optional_fields ~w(delete)a
  def direct_quantity_update_changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> quantity_update(params)
    |> set_delete_action
  end

  defp quantity_update(changeset, params) do
    changeset
    |> validate_number(:quantity, greater_than: 0)
    |> update_total_changeset(params)
  end

  defp update_total_changeset(model, params) when params == %{}, do: model
  defp update_total_changeset(model, _params) do
    quantity       = get_field(model, :quantity) |> Decimal.new
    unit_price     = get_field(model, :unit_price)
    cost           = Decimal.mult(quantity, unit_price)
    # always based on the current price
    put_change(model, :total, cost)
  end

  defp add_to_existing_quantity(changeset) do
    existing_quantity = get_field(changeset, :quantity)
    change_in_quantity = get_field(changeset, :add_quantity)
    put_change(changeset, :quantity, existing_quantity + change_in_quantity)
  end

  defp set_delete_action(changeset) do
    if get_change(changeset, :delete) do
      %{changeset| action: :delete}
    else
      changeset
    end
  end

end
