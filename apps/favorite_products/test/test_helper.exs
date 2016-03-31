ExUnit.start

Mix.Task.run "ecto.create", ~w(-r FavoriteProducts.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r FavoriteProducts.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(FavoriteProducts.Repo)

