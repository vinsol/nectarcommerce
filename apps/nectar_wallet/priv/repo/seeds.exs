# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     NectarWallet.Repo.insert!(%SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
Nectar.PaymentMethod.changeset(%Nectar.PaymentMethod{}, %{name: "nectar_wallet"}) |> Nectar.Repo.insert!
