defmodule Nectar.CheckoutView do
  use Nectar.Web, :view

  alias Nectar.Repo
  alias Nectar.CheckoutManager


  def country_names_and_ids do
    import Ecto.Query
    [{"--Select Country--", ""} | Repo.all(from c in Nectar.Country, select: {c.name, c.id})]
  end

  def state_names_and_ids do
    import Ecto.Query
    [{"--Select State--", ""} | Repo.all(from c in Nectar.State, select: {c.name, c.id})]
  end

  def has_shipping_method?(data, shipment_unit_id) do
    not is_nil(data.proposed_shipments[shipment_unit_id] )
  end

  def adjustment_row(%Nectar.Adjustment{shipment_id: shipment_id} = adjustment) when not is_nil(shipment_id) do
    content_tag :tr do
      [content_tag :td do
        to_string(adjustment.amount)
      end,
      content_tag :td do
        "shipping: #{adjustment.shipment.shipping_method.name}"
      end]
    end
  end

  def adjustment_row(%Nectar.Adjustment{tax_id: tax_id} = adjustment) when not is_nil(tax_id) do
    content_tag :tr do
      [content_tag :td do
        to_string(adjustment.amount)
      end,
      content_tag :td do
        "tax: #{adjustment.tax.name}"
      end]
    end
  end

  def braintree_client_token do
    Nectar.Gateway.Braintree.client_token
  end

  def next_step(%Nectar.Order{state: state, confirmation_status: true} = order) do
    next_state = CheckoutManager.next_state(order)
    # cannot move forward therefore must be in confirmed state.
    if next_state == state do
      "confirmed.html"
    else
      "#{next_state}.form.html"
    end
  end

  def next_step(%Nectar.Order{confirmation_status: false}) do
    "cancelled.html"
  end

  def shipment_details(%Nectar.ShipmentUnit{} = shipment_unit) do
    Enum.reduce(shipment_unit.line_items, "", fn (line_item, acc) ->
      acc <> line_item.variant.product.name <> ","
    end)
  end

  def shipping_method_selection(data, id), do: shipping_method_selection(data.proposed_shipments[id])

  def shipping_method_selection(proposed_shipments) do
    Enum.map(proposed_shipments, &({&1.shipping_method_name <> " (+#{&1.shipping_cost})", &1.shipping_method_id}))
  end

  def payment_methods_available?(%Nectar.Order{applicable_payment_methods: []}), do: false
  def payment_methods_available?(%Nectar.Order{}), do: true

  def shipping_methods_available?(%Nectar.ShipmentUnit{proposed_shipments: []}), do: false
  def shipping_methods_available?(%Nectar.ShipmentUnit{}), do: true

  def error_in_payment_method?(changeset, payment_method_id) do
    (!changeset.valid?) && changeset.params["payment"]["payment_method_id"] == to_string(payment_method_id)
  end

  def back_link(conn, %Nectar.Order{state: "cart"} = _order) do
    link "Back", to: cart_path(conn, :show), class: "btn btn-xs"
  end

  def back_link(_conn, %Nectar.Order{state: "confirmation"} = _order) do
    ""
  end

  def back_link(conn, %Nectar.Order{} = _order) do
    link "Back", to: checkout_path(conn, :back), method: "put", class: "btn btn-xs"
  end

end
