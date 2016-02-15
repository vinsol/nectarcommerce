# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ExShop.Repo.insert!(%ExShop.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
# Seed.LoadCountry.seed!
# Seed.CreateZone.seed!
# ExShop.Repo.insert!(%ExShop.User{name: "Admin", email: "admin@vinsol.com", encrypted_password: Comeonin.Bcrypt.hashpwsalt("vinsol"), is_admin: true})
# Seed.LoadSettings.seed!
Seed.LoadProducts.seed!
