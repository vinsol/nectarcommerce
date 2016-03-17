Nectar E-Commerce [![Build Status](https://travis-ci.org/vinsol/nectarcommerce.svg?branch=master)](https://travis-ci.org/vinsol/nectarcommerce)
=================

Nectar is an open source e-commerce Elixir/Phoenix project to be _evolved into E-Commerce framework **the elixir way**_
Please share your ideas [here](https://github.com/vinsol/nectarcommerce/issues/44)

It includes:

*Admin*

- Product Management
  - Manage OptionTypes/OptionValues
  - Manage Categories
  - Product with / without variants
  - Search

- Configuration Management
  - General Settings
  - Shipping Methods
  - Payment Methods
    - Stripe and Braintree supported

- Cart Management
  - Add / Remove Variant
  - Add Shipping / Billing Address
  - Choose Shipping Method
  - Choose Payment Method

- Order Management
  - Cancel LineItem
  - Fulfill Order
  - Create New Order
  - Search

- User Management
  - Create Users
  - Promote / Demote as Admin

*User*

- User Registration / Login
- Product Browsing
  - List and Search
  - on available categories
- Cart Management
- Check Order Details

Demo on Heroku
==============

- [Browse User Interface](https://nectarcommerce-demo.herokuapp.com/)
  - **Username:** alice@example.com
  - **Password:** foobar
- [Browse Admin Interface](https://nectarcommerce-demo.herokuapp.com/admin)
  - **Username:** bob@example.com
  - **Password:** secured

Getting Started
---------------

- Pre-requisites
  - [Install Elixir](http://elixir-lang.org/install.html)
    - Check `elixir -v`, better to have 1.2.2 or higher
  - [Install Hex Package Manager](https://hex.pm/docs/usage)
    - `mix local.hex`
    - Check `mix hex.info`
  - [Install Nodejs 5](https://nodejs.org/en/download/package-manager/)
  - [Install Postgres 9.4 or higher](https://wiki.postgresql.org/wiki/Detailed_installation_guides)
    - `psql postgres`
      - Check `SHOW SERVER_VERSION`
    - jsonb[] type is used and not available on previous versions


- Clone Project Locally
  - `git clone https://github.com/vinsol/nectarcommerce.git`
- Set up Development Environment
  - Copy apps/nectar/config/dev.secret.exs.example as dev.secret.exs
    - `cp apps/nectar/config/dev.secret.exs.example apps/nectar/config/dev.secret.exs`
  - Configure Postgres Database
  - Configure Arc for images upload
    - [Local Image Upload for Development](https://github.com/stavro/arc#local-configuration)
      - As uploads would be done on App Root so a symlink is needed
        - `ln -s uploads apps/nectar/priv/static/uploads` # run from project root
    - [S3 Image Upload for Production](https://github.com/stavro/arc#s3-configuration)
  - Configure Payment Methods
    - [Configure Stripe](http://www.larryullman.com/2012/11/07/creating-a-stripe-payments-test-account/) and [Test Stripe](https://stripe.com/docs/testing)
    - [Configure Braintree](https://articles.braintreepayments.com/control-panel/important-gateway-credentials) and [Test Braintree](https://developers.braintreepayments.com/reference/general/testing/ruby)
  - Get Application Dependencies
    - `mix deps.get`
  - Set-up Application Database
    - Drop Database
      - `mix ecto.drop -r Nectar.Repo`
    - Create Database
      - `mix ecto.create -r Nectar.Repo`
    - Migrate Database
      - `mix ecto.migrate -r Nectar.Repo`
    - Seed Database
      - `mix run apps/nectar/priv/repo/seeds.exs`
  - Build Assets
    - `cd apps/nectar`
    - `npm install`
    - `./node_modules/brunch/bin/brunch build`
    - Optionally might need `bower install`
  - Run Phoenix Server with IEx
    - iex -S mix phoenix.server
- Browse User Interface
  - http://localhost:4000
- Browse Admin Interface
  - http://localhost:4000/admin

Contributing
------------

1. Fork the repo.
2. Clone your repo.
3. Check [Getting Started](#getting-started)
4. Make your changes.
5. Ensure tests pass by running `mix test`.
7. Submit your pull request.

Running Tests
-------------

We use [Travis CI](https://travis-ci.org/) to run the tests for Nectar.

You can see the build statuses at [https://travis-ci.org/vinsol/nectarcommerce](https://travis-ci.org/vinsol/nectarcommerce).

RoadMap
-------

- **Evolve into a Phoenix E-commerce Framework**
  - Better and More Shipping Methods Customization
  - Better and More Payment Methods Customization
  - Customize Tax Rate Calculations
  - Customize Package Management
    - Add Order Splitters
- RealTime Updates using Channels
- Upgrade to ecto-2
- Customisable and decoupled Frontend and Backend
  - React Frontend
  - Phoenix Api Backend
- Improved Stock Management
- Returns / Refunds Management
- Payments
  - Add support for capture and refunds
- Marketing
  - Promotions
  - Email Campaigns
- More features as per contributions and use :)

Credits
-------

[![vinsol.com: Ruby on Rails, iOS and Android developers](http://vinsol.com/vin_logo.png "Ruby on Rails, iOS and Android developers")](http://vinsol.com)

Copyright (c) 2016 [vinsol.com](http://vinsol.com "Ruby on Rails, iOS and Android developers"), released under the New MIT License
