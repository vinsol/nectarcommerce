defmodule Nectar.Admin.PaymentView do
  use Nectar.Web, :view

  alias Nectar.Payment

  defdelegate authorized?(payment), to: Nectar.Payment
  defdelegate captured?(payment), to: Nectar.Payment
  defdelegate refunded?(payment), to: Nectar.Payment

end
