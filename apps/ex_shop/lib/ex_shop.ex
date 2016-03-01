defmodule ExShop do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      supervisor(ExShop.Endpoint, []),
      # Start the Ecto repository
      supervisor(ExShop.Repo, []),
      # Here you could define other workers and supervisors as children
      # worker(ExShop.Worker, [arg1, arg2, arg3]),

      worker(Commerce.Billing.Worker, stripe_worker_configuration, id: :stripe),
      worker(Commerce.Billing.Worker, braintree_worker_configuration, id: :braintree)
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExShop.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ExShop.Endpoint.config_change(changed, removed)
    :ok
  end

  def stripe_worker_configuration do
    worker_config = Application.get_env(:ex_shop, :stripe)
    gateway_type = worker_config[:type]
    settings = %{credentials: worker_config[:credentials],
                 default_currency: worker_config[:default_currency]}
    [gateway_type, settings, [name: :stripe]]
  end

  def braintree_worker_configuration do
    worker_config = Application.get_env(:ex_shop, :braintree)
    gateway_type = worker_config[:type]
    settings = %{}
    [gateway_type, settings, [name: :braintree]]
  end
end
