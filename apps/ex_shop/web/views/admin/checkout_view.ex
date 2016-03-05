defmodule ExShop.Admin.CheckoutView do
	use ExShop.Web, :view

  alias ExShop.Repo
  alias ExShop.CheckoutManager

  import Ecto.Query

  def country_names_and_ids do
    Repo.all(from c in ExShop.Country, select: {c.name, c.id})
  end

  def state_names_and_ids do
    Repo.all(from c in ExShop.State, select: {c.name, c.id})
  end

  def adjustment_row(%ExShop.Adjustment{shipping_id: shipping_id} = adjustment) when not is_nil(shipping_id) do
    content_tag :tr do
      [content_tag :td do
        to_string(adjustment.amount)
      end,
      content_tag :td do
        "shipping: #{adjustment.shipping.shipping_method.name}"
      end]
    end
  end

  def adjustment_row(%ExShop.Adjustment{tax_id: tax_id} = adjustment) when not is_nil(tax_id) do
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
    ExShop.Gateway.BrainTree.client_token
  end

  def next_step(%ExShop.Order{state: state, confirmation_status: true} = order) do
    next_state = CheckoutManager.next_state(order)
    # cannot move forward therefore must be in confirmed state.
    if next_state == state do
      "confirmed.html"
    else
      "#{next_state}.form.html"
    end
  end

  def next_step(%ExShop.Order{confirmation_status: false}) do
    "cancelled.html"
  end

  def payment_methods_available?(%ExShop.Order{applicable_payment_methods: []}), do: false
  def payment_methods_available?(%ExShop.Order{}), do: true

  def shipping_methods_available?(%ExShop.Order{applicable_shipping_methods: []}), do: false
  def shipping_methods_available?(%ExShop.Order{}), do: true

end
