ExUnit.start

Mix.Task.run "ecto.create", ~w(-r NectarCore.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r NectarCore.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(NectarCore.Repo)

