ExUnit.start

Mix.Task.run "ecto.create", ~w(-r ExShop.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r ExShop.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(ExShop.Repo)

