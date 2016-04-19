defmodule Nectar.Admin.CheckoutView do
  use NectarCore.Web, :view

  alias Nectar.Repo
  alias Nectar.CheckoutManager

  import Ecto.Query

  def country_names_and_ids do
    [{"--Select Country--", ""} | Repo.all(from c in Nectar.Country, select: {c.name, c.id})]
  end

  def state_names_and_ids do
    [{"--Select State--", ""} | Repo.all(from c in Nectar.State, select: {c.name, c.id})]
  end

  def adjustment_row(%Nectar.Adjustment{shipping_id: shipping_id} = adjustment) when not is_nil(shipping_id) do
    content_tag :tr do
      [content_tag :td do
        to_string(adjustment.amount)
      end,
      content_tag :td do
        "shipping: #{adjustment.shipping.shipping_method.name}"
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
    Nectar.Gateway.BrainTree.client_token
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

  def payment_methods_available?(%Nectar.Order{applicable_payment_methods: []}), do: false
  def payment_methods_available?(%Nectar.Order{}), do: true

  def shipping_methods_available?(%Nectar.Order{applicable_shipping_methods: []}), do: false
  def shipping_methods_available?(%Nectar.Order{}), do: true

  def error_in_payment_method?(changeset, payment_method_id) do
    (!changeset.valid?) && changeset.params["payment"]["payment_method_id"] == to_string(payment_method_id)
  end

  def back_link(conn, %Nectar.Order{state: "cart"} = order) do
    link "Back", to: NectarRoutes.admin_cart_path(conn, :edit, order), class: "btn btn-xs"
  end

  def back_link(_conn, %Nectar.Order{state: "confirmation"} = _order) do
    ""
  end

  def back_link(conn, %Nectar.Order{} = order) do
    link "Back", to: NectarRoutes.admin_order_checkout_path(conn, :back, order), method: "put", class: "btn btn-xs"
  end

end
