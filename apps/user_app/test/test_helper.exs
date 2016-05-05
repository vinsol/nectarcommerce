ExUnit.start

Mix.Task.run "ecto.create", ~w(-r UserApp.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Nectar.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r FavoriteProducts.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r UserApp.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(UserApp.Repo)

