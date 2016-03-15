ExUnit.configure(exclude: [pending: true])
ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Nectar.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Nectar.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Nectar.Repo)

