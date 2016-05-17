defmodule Nectar.Admin.PaymentView do
  use Nectar.Web, :view

  alias Nectar.Payment

  def payment_not_captured(%Payment{payment_state: "captured"}), do: false
  def payment_not_captured(_), do: true
  def payment_not_refunded(%Payment{payment_state: "refunded"}), do: false
  def payment_not_refunded(_), do: true

end
