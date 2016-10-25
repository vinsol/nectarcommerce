defmodule Nectar.TestSetup.Adjustment do
  def valid_attrs, do: %{shipment_id: -1, tax_id: -1, order_id: -1, amount: 0.0}
  def invalid_attrs, do: %{shipment_id: -1, tax_id: -1, order_id: -1}
end
