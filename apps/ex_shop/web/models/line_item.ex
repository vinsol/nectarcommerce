defmodule ExShop.LineItem do
  use ExShop.Web, :model
  alias ExShop.Order
  alias ExShop.Variant
  alias ExShop.Product
  alias ExShop.Repo

  schema "line_items" do
    belongs_to :variant, ExShop.Variant
    belongs_to :order, ExShop.Order
    field :quantity, :integer
    field :total, :decimal
    field :fullfilled, :boolean, default: true
    timestamps
  end

  # @required_fields ~w()
  # @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> create_changeset(params)
    |> quantity_changeset(params)
  end

  def fullfillment_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(fullfilled), ~w())
  end

  def create_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(order_id), ~w())
    |> foreign_key_constraint(:order_id)
    |> ensure_product_has_no_variants_if_master()
  end

  def quantity_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(quantity), ~w(fullfilled))
    |> add_to_existing_quantity
    |> validate_number(:quantity, greater_than: 0)
    |> preload_assoc
    |> validate_product_availability
    |> update_total_changeset(params)
  end

  defp update_total_changeset(model, params) do
    quantity = get_field(model, :quantity)
    variant  = get_field(model, :variant)
    cost = Decimal.mult(Decimal.new(quantity), variant.cost_price)
    cast(model, Map.merge(params, %{total: cost}), ~w(total), ~w())
  end

  defp add_to_existing_quantity(changeset) do
    existing_quantity = changeset.model.quantity
    change_in_quantity = changeset.changes[:quantity]
    cond do
      existing_quantity && change_in_quantity -> put_change(changeset, :quantity, existing_quantity + change_in_quantity)
      existing_quantity -> put_change(changeset, :quantity, existing_quantity * 2)
      true -> changeset
    end
  end

  def move_stock(%ExShop.LineItem{fullfilled: true} = line_item) do
    acquire_stock_from_variant(line_item)
  end
  def move_stock(%ExShop.LineItem{fullfilled: false} = line_item) do
    restock_variant(line_item)
  end

  def acquire_stock_from_variant(%ExShop.LineItem{variant: variant, quantity: quantity, fullfilled: true}) do
    variant
    |> Variant.buy_changeset(%{buy_count: quantity})
    |> Repo.update!
  end

  def acquire_stock_from_variant(%ExShop.LineItem{variant: variant, quantity: quantity}) do
    variant
  end

  def restock_variant(%ExShop.LineItem{variant: variant, quantity: quantity, fullfilled: false}) do
    variant
    |> Variant.restocking_changeset(%{restock_count: quantity})
    |> Repo.update!
  end

  def restock_variant(%ExShop.LineItem{variant: variant, quantity: quantity}) do
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

  defp preload_assoc(%ExShop.LineItem{} = line_item) do
    Repo.preload(line_item, [:variant, :order])
  end

  def sufficient_quantity_available?(%ExShop.LineItem{} = line_item) do
    requested_quantity = line_item.quantity
    sufficient_quantity_available?(line_item, requested_quantity)
  end

  def sufficient_quantity_available?(%ExShop.LineItem{} = line_item, requested_quantity) do
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
    case Ecto.Date.compare(discontinue_on, Ecto.Date.utc) do
      :lt -> add_error(changeset, :variant, "has been discontinued")
       _  -> changeset
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

end
