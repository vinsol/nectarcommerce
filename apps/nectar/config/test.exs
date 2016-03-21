use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :nectar, Nectar.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :nectar, Nectar.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "",
  database: "nectar_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :nectar, :shipping_calculators,
  regular: Nectar.ShippingCalculator.Flat,
  express: Nectar.ShippingCalculator.Random,
  simple: Nectar.ShippingCalculatorTest.Simple,
  provided: Nectar.ShippingCalculatorTest.ProvidedShippingRate,
  overriden_shipping_rate: Nectar.ShippingCalculatorTest.OverridenShippingRate,
  throws_exception: Nectar.ShippingCalculatorTest.ThrowsException,
  times_out: Nectar.ShippingCalculatorTest.TimesOut,
  not_applicable: Nectar.ShippingCalculatorTest.NotApplicable
