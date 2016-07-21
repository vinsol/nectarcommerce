defmodule Nectar.Command.Order do
  use Nectar.Command, model: Nectar.Order

  def insert!(_repo, _params), do: raise "insert not allowed, please use other commands"
  def insert(_repo, _params),  do: raise "insert not allowed, please use other commands"
  def update(_repo, _params),  do: raise "please use the proper workflow for updating order"
  def update(_repo, _params),  do: raise "please use the proper workflow for updating order"

  def create_empty_cart_for_guest!(repo),
    do: Nectar.Order.cart_changeset(%Nectar.Order{}, %{}) |> repo.insert!

  def create_empty_cart_for_user!(repo, user_id),
    do: Nectar.Order.user_cart_changeset(%Nectar.Order{}, %{user_id: user_id}) |> repo.insert!

  def update_with_order_settlement(repo, order, params) do
    Nectar.Order.settlement_changeset(order, params)
    |> repo.update
  end

  def delete_addresses(repo, order) do
    repo.transaction(fn ->
      repo.delete_all(Nectar.Query.Order.shipping_address(order))
      repo.delete_all(Nectar.Query.Order.billing_address(order))
    end)
  end

  def delete_payment(repo, order) do
   repo.delete_all(Nectar.Query.Order.payment(order))
  end

  def delete_tax_adjustments(repo, order) do
    repo.delete_all(Nectar.Query.Order.tax_adjustments(order))
  end

  def delete_shipment_units(repo, order) do
    repo.delete_all(Nectar.Query.Order.shipment_units(order))
  end

  def delete_shipment_adjustments(repo, order) do
    repo.delete_all(Nectar.Query.Order.shipment_adjustments(order))
  end

  def delete_shipments(repo, order) do
    repo.delete_all(Nectar.Query.Order.shipments(order))
  end

end
