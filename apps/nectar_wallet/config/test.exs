use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :nectar_wallet, NectarWallet.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :nectar_wallet, NectarWallet.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "nectar_wallet_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
