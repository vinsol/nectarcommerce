defmodule NectarWallet.NectarExtension do
  # TODO: write up a common dsl for this in nectar
  # the we can update the code as
  # use Nectar.Extension
  # extend "users" do
  #   add_to_schema calls
  #   add_to_method calls
  # end
  # extend "router" do
  #  define_route calls
  # end
  defmacro __using__([install: install_type]) do
    do_install(install_type)
  end

  defp do_install("users") do
    quote do
      add_to_schema(:has_one, :wallet, NectarWallet.Wallet, [])
    end
  end

  defp do_install("router") do
    quote do
      define_route do
        scope "/wallet", NectarWallet do
          pipe_through [:browser, :browser_auth]
          get "/", WalletController, :edit
          put "/", WalletController, :update
        end
      end
    end
  end

  defp do_install("checkout_view") do
    quote do
      provide_partial(NectarWallet.WalletView, "payment.nectar_wallet.html")
    end
  end
end
