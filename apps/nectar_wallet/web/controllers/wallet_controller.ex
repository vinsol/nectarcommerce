defmodule NectarWallet.WalletController do
  use Nectar.Web, :controller

  plug Guardian.Plug.EnsureAuthenticated, handler: __MODULE__
  alias NectarWallet.Router.Helpers, as: ExtensionRouteHelpers
  alias NectarWallet.Wallet

  def edit(conn, _params) do
    wallet = get_wallet(conn)
    changeset = Wallet.add_points_changeset(wallet, %{})
    conn
    |> render("edit.html", changeset: changeset, wallet: wallet, action: ExtensionRouteHelpers.wallet_path(conn, :update))
  end

  def update(conn, %{"wallet" => wallet_params}) do
    wallet = get_wallet(conn)
    changeset = Wallet.add_points_changeset(wallet, wallet_params)
    case Repo.update(changeset) do
      {:ok, wallet} ->
        conn
        |> put_flash(:success, "updated successfully")
        |> render("edit.html", wallet: wallet, changeset: Wallet.add_points_changeset(wallet, %{}), action: ExtensionRouteHelpers.wallet_path(conn, :update))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "failed to update, please see below for errors")
        |> render("edit.html", wallet: wallet, changeset: changeset, action: ExtensionRouteHelpers.wallet_path(conn, :update))
    end
  end

  defp get_wallet(conn) do
    # every user has a wallet, if not create and provide one
    current_user = Guardian.Plug.current_resource(conn)
    case Repo.get_by(Wallet, user_id: current_user.id) do
      nil    -> Repo.insert!(Wallet.changeset(%Wallet{}, %{"user_id" => current_user.id}))
      wallet -> wallet
    end
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_flash(:error, "Please login to add money to your wallet")
    |> redirect(to: session_path(conn, :new))
    |> halt
  end

end
