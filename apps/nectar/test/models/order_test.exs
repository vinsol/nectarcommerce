defmodule Nectar.OrderTest do
  use Nectar.ModelCase
  alias Nectar.Order
  describe "fields" do
    fields =
      ~w(id slug state total confirmation_status product_total)a ++
      ~w(order_state user_id)a ++
      timestamps
    has_fields Order, fields
  end

  describe "associations" do
    assocs =
      ~w(line_items shipment_units shipments adjustments shipping variants)a ++
      ~w(user order_billing_address billing_address order_shipping_address)a ++
      ~w(payment shipping_address)a
    has_associations Order, assocs

    has_many?     Order, :line_items, via: Nectar.LineItem
    has_many?     Order, :shipments, through: [:shipment_units, :shipment]
    has_one?      Order, :order_shipping_address, via: Nectar.OrderShippingAddress
    has_one?      Order, :shipping_address, through: [:order_shipping_address]
    has_one?      Order, :payment, via: Nectar.Payment
    belongs_to?   Order, :user, via: Nectar.User
    belongs_to?   Order, :line_items, via: Nectar.User

  end
end
