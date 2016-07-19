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
    field :quantity, :integer
    field :total, :decimal
    field :fullfilled, :boolean, default: true

    field :delete, :boolean, virtual: true
    timestamps
    extensions
  end

  def cancel_fullfillment(%Nectar.LineItem{fullfilled: false} = line_item), do: line_item

  def cancel_fullfillment(%Nectar.LineItem{fullfilled: true} = line_item) do
    Nectar.Repo.transaction(fn ->
      changeset = fullfillment_changeset(line_item, %{fullfilled: false})
      case Nectar.Repo.update(changeset) do
        {:ok, line_item} ->
          line_item = preload_assoc(line_item)
          move_stock(line_item)
          Order.settle_adjustments_and_product_payments(line_item.order)
          line_item
        {:error, changeset} ->
          Nectar.Repo.rollback changeset
      end
    end)
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
    |> ensure_order_is_confirmed
  end

  @required_fields ~w(order_id unit_price)a
  @optional_fields ~w()a
  def create_changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
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
    # always based on the curren price
    put_change(model, :total, cost)
  end

  defp add_to_existing_quantity(changeset) do
    existing_quantity = changeset.data.quantity || 0
    change_in_quantity = changeset.changes[:add_quantity] || 0
    put_change(changeset, :quantity, existing_quantity + change_in_quantity)
  end

  def move_stock(%Nectar.LineItem{fullfilled: true} = line_item) do
    acquire_stock_from_variant(line_item)
  end
  def move_stock(%Nectar.LineItem{fullfilled: false} = line_item) do
    restock_variant(line_item)
  end

  def acquire_stock_from_variant(%Nectar.LineItem{variant: variant, quantity: quantity, fullfilled: true}) do
    variant
    |> Variant.buy_changeset(%{buy_count: quantity})
    |> Repo.update!
  end

  # do not acquire any stock if line item is not fullfilled
  def acquire_stock_from_variant(%Nectar.LineItem{variant: variant, quantity: _quantity}) do
    variant
  end

  def restock_variant(%Nectar.LineItem{variant: variant, quantity: quantity, fullfilled: false}) do
    variant
    |> Variant.restocking_changeset(%{restock_count: quantity})
    |> Repo.update!
  end

  def restock_variant(%Nectar.LineItem{variant: variant, quantity: _quantity}) do
    variant
  end

  # assures that the product is preloaded before validation
  # of the quantity
  defp preload_assoc(%Ecto.Changeset{} = changeset) do
    %Ecto.Changeset{changeset| data: preload_assoc(changeset.data)}
  end

  defp preload_assoc(%Nectar.LineItem{} = line_item) do
    Repo.preload(line_item, [:variant, :order])
  end

  defp ensure_order_is_confirmed(changeset) do
    order = changeset.data |> Repo.preload([:order]) |> Map.get(:order)
    if Order.confirmed?(order) do
      changeset
    else
      add_error(changeset, :fullfilled, "Order should be in confirmation state before updating the fullfillment status")
    end
  end

  defp set_delete_action(changeset) do
    if get_change(changeset, :delete) do
      %{changeset| action: :delete}
    else
      changeset
    end
  end

  def set_shipment_unit(line_item_ids, shipment_unit_id) do
    from line_item in Nectar.LineItem,
      where: line_item.id in ^line_item_ids,
      update: [set: [shipment_unit_id: ^shipment_unit_id]]
  end
end
