defmodule Nectar.Admin.PaymentView do
  use Nectar.Web, :view

  alias Nectar.Payment

  defdelegate authorized?(payment), to: Payment
  defdelegate captured?(payment), to: Payment
  defdelegate refunded?(payment), to: Payment

end
