defmodule Nectar.Billing.Gateways.NectarWalletGateway do
  use Commerce.Billing.Gateways.Base

  alias Nectar.Repo
  alias NectarWallet.Wallet

  def authorize(user_id, amount, options \\ %{})

  def authorize(nil, amount, _opts), do: {:error, "cannot pay by wallet for guest order"}
  def authorize(user_id, amount, _opts) do
    case Repo.get_by(Wallet, user_id: user_id) do
      nil -> {:error, "wallet not found"}
      wallet -> do_authorize_payment(wallet, amount)
    end
  end

  defp do_authorize_payment(wallet, amount) do
    deduction_change = Wallet.deduction_changeset(wallet, %{deduct_amount: amount})
    case Repo.update(deduction_change) do
      {:error, changeset} -> {:error, changeset.errors[:deduct_amount]}
      {:ok, wallet} -> {:ok, "success"}
    end
  end

end
