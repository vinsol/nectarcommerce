# Setup

- mix deps.get
- mix ecto.drop; mix ecto.create; mix ecto.migrate
- mix run priv/repo/seeds.exs
- mix phoenix.server
  - Open http://localhost:4000
  - Find _Admin Login_ at top and click
  - Fill username and password
  - See Homepage



# Technical Development

- [ ] Admin Login using Guardian
- [ ] Configuration Data Management
  - [ ] Zones
  - [ ] Countries
  - [ ] States
  - [ ] Currencies
- [ ] Product Management
- [ ] Order Management
- [ ] Logistics Management
- [ ] Returns / Refunds Management
- [ ] User Management
- [ ] Cart/Checkout Management
- [ ] Payment Management
- [ ] Marketing
  - [ ] Promotions
  - [ ] Email Campaigns
