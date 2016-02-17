defmodule ExShop.Admin.CheckoutView do
	use ExShop.Web, :view

  alias ExShop.Repo
  import Ecto.Query

  def country_names_and_ids do
    Repo.all(from c in ExShop.Country, select: {c.name, c.id})
  end

  def state_names_and_ids do
    Repo.all(from c in ExShop.State, select: {c.name, c.id})
  end

  def adjustment_row(%ExShop.Adjustment{shipping_id: shipping_id} = adjustment) when not is_nil(shipping_id) do
    if adjustment.shipping.selected do
      content_tag :tr do
        [content_tag :td do
          to_string(adjustment.amount)
        end,
        content_tag :td do
          "shipping: #{adjustment.shipping.shipping_method.name}"
        end]
      end
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

end
