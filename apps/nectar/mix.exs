defmodule Nectar.Mixfile do
  use Mix.Project

  def project do
    [app: :nectar,
     version: "0.0.1",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     deps: deps]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Nectar, []},
      applications: [
        :phoenix, :phoenix_html, :cowboy, :logger, :gettext,
        :phoenix_ecto, :postgrex, :worldly, :yamerl, :commerce_billing, :braintree,
        :ex_aws, :httpoison
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.1.4"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_ecto, "~> 2.0", override: true},
      {:phoenix_html, "~> 2.4"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.9"},
      {:cowboy, "~> 1.0"},
      {:comeonin, "~> 2.1"},
      {:guardian, "~> 0.9.0"},
      {:ex_aws, "~> 0.4.10"},
      {:arc_ecto, "~> 0.3.2"},
      {:commerce_billing, github: "nimish-mehta/commerce_billing",  override: true},
      {:braintree, "~> 0.3.2"},
      {:worldly, in_umbrella: true},
      {:nectar_checkout_, in_umbrella: true},
      {:nectar_accounts, in_umbrella: true},
      {:nectar_inventory, in_umbrella: true},
      {:nectar_order_processing, in_umbrella: true}
    ]
  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"]]
  end
end
