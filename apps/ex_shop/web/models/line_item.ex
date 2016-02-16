defmodule ExShop.LineItem do
	use ExShop.Web, :model
  alias ExShop.Order
  alias ExShop.NotProduct, as: Product
  alias ExShop.Repo

  schema "line_items" do
    belongs_to :product, ExShop.NotProduct
    belongs_to :order, ExShop.Order
    field :quantity, :integer
    field :total, :decimal

    timestamps
  end

  # @required_fields ~w()
  # @optional_fields ~w()


  def changeset(model, params \\ :empty) do
    model
    |> order_id_changeset(params)
    |> quantity_changeset(params)
  end

  def order_id_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(order_id), ~w())
  end

  def quantity_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(quantity), ~w())
    |> validate_number(:quantity, greater_than: 0)
    |> preload_assoc
    |> validate_product_availability
    |> update_total_changeset(params)
  end

  defp update_total_changeset(model, params \\ :empty) do
    quantity = get_field(model, :quantity)
    product  = get_field(model, :product)
    cost = Decimal.mult(Decimal.new(quantity), product.cost )
    cast(model, Dict.merge(params, %{total: cost}), ~w(total), ~w())
  end

  def in_order(query, %Order{id: order_id}) do
    from c in query, where: c.order_id == ^order_id
  end

  def with_product(query, %Product{id: product_id}) do
    from c in query, where: c.product_id == ^product_id
  end

  # assures that the product is preloaded before validation
  # of the quantity
  defp preload_assoc(%Ecto.Changeset{} = changeset) do
    model_from_changeset = changeset.model
    %Ecto.Changeset{changeset| model: Repo.preload(model_from_changeset, [:product, :order])}
  end
  defp preload_assoc(%ExShop.LineItem{} = line_item) do
    Repo.preload(line_item, [:product, :order])
  end

  def validate_product_availability(%ExShop.LineItem{} = line_item) do
    quantity = line_item.quantity
    # have to make sure product is preloaded
    product_quantity = line_item.product.quantity
    if quantity > product_quantity do
      add_error(line_item, :quantity, "only #{product_quantity} available")
    else
      line_item
    end
  end

  def validate_product_availability(model) do
    quantity = get_field(model, :quantity)
    # have to make sure product is preloaded
    product_quantity = get_field(model, :product).quantity
    if quantity > product_quantity do
      add_error(model, :quantity, "only #{product_quantity} available")
    else
      model
    end
  end



end
