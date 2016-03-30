defmodule NectarWallet do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      # supervisor(NectarWallet.Endpoint, []),
      # Start the Ecto repository
      # worker(NectarWallet.Repo, []),
      # Here you could define other workers and supervisors as children
      # worker(NectarWallet.Worker, [arg1, arg2, arg3]),
      worker(Commerce.Billing.Worker, nectar_wallet_config, id: :nectar_wallet)
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NectarWallet.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    NectarWallet.Endpoint.config_change(changed, removed)
    :ok
  end

  defp nectar_wallet_config do
    gateway_type = Nectar.Billing.Gateways.NectarWalletGateway
    [gateway_type, %{}, [name: :nectar_wallet]]
  end
end
