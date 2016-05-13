defmodule Nectar.LineItem do
  use Nectar.Web, :model

  alias Nectar.Order
  alias Nectar.Variant
  alias Nectar.Product
  alias Nectar.Repo

  schema "line_items" do
    belongs_to :variant, Nectar.Variant
    belongs_to :order, Nectar.Order

    has_many :line_item_returns, Nectar.LineItemReturn

    field :add_quantity, :integer, virtual: true, default: 0
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
      case line_item
      |> fullfillment_changeset(%{fullfilled: false})
      |> Nectar.Repo.update do
        {:ok, line_item} ->
          create_line_item_return(line_item)
          line_item
        {:error, changeset} ->
          Nectar.Repo.rollback changeset
      end
    end)
  end

  def create_line_item_return(line_item) do
    line_item
      |> build_assoc(:line_item_returns)
      |> Nectar.LineItemReturn.changeset(%{
          "quantity" => line_item.quantity,
          "status" => Nectar.LineItemReturn.get_status("pending")
        })
      |> Nectar.Repo.insert!
  end

  def changeset(model, params \\ :empty) do
    model
    |> create_changeset(params)
    |> quantity_changeset(params)
  end

  def fullfillment_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(fullfilled), ~w())
    |> ensure_order_is_confirmed
  end

  def create_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(order_id), ~w())
    |> foreign_key_constraint(:order_id)
    |> ensure_product_has_no_variants_if_master()
  end

  def quantity_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(), ~w(fullfilled add_quantity))
    |> add_to_existing_quantity
    |> quantity_update(params)
  end

  def direct_quantity_update_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(quantity), ~w(delete))
    |> quantity_update(params)
    |> set_delete_action
  end

  defp quantity_update(changeset, params) do
    changeset
    |> validate_number(:quantity, greater_than: 0)
    |> preload_assoc
    |> validate_product_availability
    |> update_total_changeset(params)
  end

  defp update_total_changeset(model, :empty), do: model
  defp update_total_changeset(model, _params) do
    quantity = get_field(model, :quantity)
    variant  = get_field(model, :variant)
    cost = Decimal.mult(Decimal.new(quantity), variant.cost_price)
    put_change(model, :total, cost)
  end

  defp add_to_existing_quantity(changeset) do
    existing_quantity = changeset.model.quantity || 0
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

  def in_order(query, %Order{id: order_id}) do
    from c in query, where: c.order_id == ^order_id
  end

  def with_variant(query, %Variant{id: variant_id}) do
    from c in query, where: c.variant_id == ^variant_id
  end

  # assures that the product is preloaded before validation
  # of the quantity
  defp preload_assoc(%Ecto.Changeset{} = changeset) do
    %Ecto.Changeset{changeset| model: preload_assoc(changeset.model)}
  end

  defp preload_assoc(%Nectar.LineItem{} = line_item) do
    Repo.preload(line_item, [:variant, :order])
  end

  def sufficient_quantity_available?(%Nectar.LineItem{} = line_item) do
    requested_quantity = line_item.quantity
    sufficient_quantity_available?(line_item, requested_quantity)
  end

  def sufficient_quantity_available?(%Nectar.LineItem{} = line_item, nil) do
    available_product_quantity = line_item.variant |> Variant.available_quantity
    {true, available_product_quantity}
  end

  def sufficient_quantity_available?(%Nectar.LineItem{} = line_item, requested_quantity) do
    available_product_quantity = line_item.variant |> Variant.available_quantity
    {requested_quantity <= available_product_quantity, available_product_quantity}
  end

  def validate_product_availability(changeset) do
    changeset
    |> validate_available_product_quantity
    |> validate_product_discontinuation_date
  end

  defp validate_available_product_quantity(changeset) do
    case sufficient_quantity_available?(changeset.model, changeset.changes[:quantity]) do
      {true, _} -> changeset
      {false, 0} -> add_error(changeset, :variant, "out of stock")
      {false, available_product_quantity} -> add_error(changeset, :quantity, "only #{available_product_quantity} available")
    end
  end

  defp validate_product_discontinuation_date(changeset) do
    discontinue_on = changeset.model.variant.discontinue_on
    if discontinue_on do
      case Ecto.Date.compare(discontinue_on, Ecto.Date.utc) do
        :lt -> add_error(changeset, :variant, "has been discontinued")
        _  -> changeset
      end
    else
      changeset
    end
  end

  defp ensure_product_has_no_variants_if_master(changeset) do
    variant =
      changeset.model
      |> Repo.preload([variant: :product])
      |> Map.get(:variant)
    if variant.is_master and Product.has_variants_excluding_master?(variant.product) do
      add_error(changeset, :variant, "cannot add master variant to cart when other variants are present.")
    else
      changeset
    end
  end

  defp ensure_order_is_confirmed(changeset) do
    order = changeset.model |> Repo.preload([:order]) |> Map.get(:order)
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
end
