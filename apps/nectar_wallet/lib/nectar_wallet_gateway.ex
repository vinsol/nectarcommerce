defmodule Nectar.Gateway.NectarWallet do
  def authorize(order, _params) do
    case Billing.authorize(:nectar_wallet, order.user_id, order.total) do
      {:ok, _} -> {:ok}
      {:error, _} -> {:error, "failed to pay via wallet"}
    end
  end
end
