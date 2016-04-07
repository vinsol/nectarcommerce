---
layout: post
cover: 'assets/images/general-cover-3.jpg'
title: Developing Nectar Extensions Part 1
tags: docs
subclass: 'post tag-docs'
categories: 'elixir'
author: 'Nimish'
navigation: true
logo: 'assets/images/nectar-cart.png'
---

Developing Nectar Extensions Part 1
=================


### Where we left off ###


In the past few blogs we have learned how to write code that extends existing models, routers, added methods to override view rendering and run multiple phoenix application together in the same umbrella project. Let's Continue to build upon that and write our first extension for nectar (favorite products reference the original post here) and ultimately our store based on nectar.


### A layered guide to nectar extensions ###


__Setup__: Create a new phoenix application to hold the favorite products application, in your shell run inside the umbrella/apps folder:


```bash
mix phoenix.new favorite_products
```


We could have gone with a regular mix application, but phoenix/ecto will come in handy in this case, since we want to have views to display stuff and a model to store data.

While we are at it let's configure our dev.exs and test.exs to use the same db as nectar, we could write some code and share the db settings between nectar and our extensions see: link to running multiple phoenix application together for more details. But now for simplicity's sake we are  just copying the settings from nectar to get started.

__DB_SETTINGS__:

```elixir
config :favorite_products, FavoriteProducts.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "",
  database: "nectar_dev",
  hostname: "localhost",
  pool_size: 10
```

We need to let the extension manager know that this application is an extension for nectar.
Update the dependencies in extension\_manager/mix.exs with the favorite_products depenedency.

```elixir
 defp deps do
   [{:favorite_products, in_umbrella: true}]
 end
```

That should be enough to get us going.

__MODEL LAYER__: We want a nectar user to have some products to like and a way to remember them in short a join table and with two associations let's generate them:

```bash
cd favorite_products
mix phoenix.gen.model UserLike user_like user_id:references:users product_id:references:products
```

Now to point to correct nectar models. open up the source and change the associations from favorite products model to nectar models. in the end we have a schema like:

```elixir
  schema "user_likes" do
    belongs_to :user, Nectar.User
    belongs_to :product, Nectar.Product

    timestamps
  end
```

Of, course this is only the extension view of this relationship, We want the nectar user to be aware of this relationship and most important of all, we should be able to do something like

```elixir
Nectar.User.liked_products(user) # fetches the products liked by the user
```

Time to call our handy macros written earlier to perform the black magic of compile time code injection. Let's create the nectar\_extension.ex file in favorite_products/lib/ directory and place this code there:

```elixir
defmodule FavoriteProducts.NectarExtension do
  defmacro __using__([install: install_type]) do
    do_install(install_type)
  end
  defp do_install("products") do
    quote do
      # In Phoenix App Model Schema definition, join association is defined first and then through association
      # Please note the reverse order here as while collecting, it gets collected in the reverse order.
      add_to_schema(:has_many, :liked_by, through: [:likes, :user])
      add_to_schema(:has_many, :likes, FavoriteProducts.UserLike, [])
      include_method do

        def like_changeset(model, params \\ :empty) do
          model
          |> cast(params, ~w(), ~w())
          |> cast_assoc(:likes) # will be passed the user id here.
        end

        def liked_by(model) do
          from like in assoc(model, :liked_by)
        end
      end
    end
  end

  defp do_install("users") do
    quote do
      add_to_schema(:has_many, :liked_products, through: [:likes, :product])
      add_to_schema(:has_many, :likes, FavoriteProducts.UserLike, [])
      include_method do

        def liked_products(model) do
          from like in assoc(model, :liked_products)
        end
      end
    end
  end
end
```

Don't forget to update the install file in extensions_manager.

```elixir
defmodule ExtensionsManager.ExtendProduct do
  use ExtensionsManager.ModelExtension
  use FavoriteProducts.NectarExtension, install: "products"
end

defmodule ExtensionsManager.ExtendUser do
  use ExtensionsManager.ModelExtension
  use FavoriteProducts.NectarExtension, install: "users"
end
```

Now we have a user that can like products and product from which we can query which users liked it.

Time to play with what we have built so far, start a shell in nectar folder ```iex -S mix```

```elixir
{% raw %}
iex(1)> Nectar.User.__schema__(:associations)
[:orders, :user_addresses, :addresses, :likes, :liked_products]
# added our association in user
iex(2)> Nectar.Product.__schema__(:associations)
[:master, :variants, :product_option_types, :option_types, :product_categories,
 :categories, :likes, :liked_by]
# added our association in product
# now to try insert a record.
iex(3)> changeset = FavoriteProducts.UserLike.changeset(%FavoriteProducts.UserLike{}, %{user_id: 1, product_id: 1})
iex(4)> Nectar.Repo.insert(changeset)
[debug] BEGIN [] OK query=0.5ms
[debug] INSERT INTO "user_likes" ("inserted_at", "updated_at", "product_id", "user_id") VALUES ($1, $2, $3, $4) RETURNING "id" [{{2016, 4, 6}, {12, 52, 31, 0}}, {{2016, 4, 6}, {12, 52, 31, 0}}, 1, 1] ERROR query=0.5ms
[debug] ROLLBACK [] OK query=0.4ms
** (Postgrex.Error) ERROR (undefined_table): relation "user_likes" does not exist
    (ecto) lib/ecto/adapters/sql.ex:496: Ecto.Adapters.SQL.model/6
    (ecto) lib/ecto/repo/schema.ex:297: Ecto.Repo.Schema.apply/5
    (ecto) lib/ecto/repo/schema.ex:81: anonymous fn/11 in Ecto.Repo.Schema.do_insert/4
    (ecto) lib/ecto/repo/schema.ex:477: anonymous fn/3 in Ecto.Repo.Schema.wrap_in_transaction/9
    (ecto) lib/ecto/pool.ex:292: Ecto.Pool.with_rollback/3
    (ecto) lib/ecto/adapters/sql.ex:582: Ecto.Adapters.SQL.transaction/8
    (ecto) lib/ecto/pool.ex:244: Ecto.Pool.outer_transaction/6
    (ecto) lib/ecto/adapters/sql.ex:551: Ecto.Adapters.SQL.transaction/3
{% endraw %}
```


Oops, forgot the migration, remember we shared the db config earlier let's put that to use and run:

```bash
mix ecto.migrate -r FavoriteProducts.Repo
```
which will migrate the user_likes table onto the original nectar database.

now back to our shell

```elixir
{% raw %}
iex(4)> Nectar.Repo.insert!(changeset)
[debug] BEGIN [] OK query=98.6ms queue=14.8ms
[debug] INSERT INTO "user_likes" ("inserted_at", "updated_at", "product_id", "user_id") VALUES ($1, $2, $3, $4) RETURNING "id" [{{2016, 4, 6}, {12, 57, 31, 0}}, {{2016, 4, 6}, {12, 57, 31, 0}}, 1, 1] OK query=2.3ms
[debug] COMMIT [] OK query=2.3ms
%FavoriteProducts.UserLike{__meta__: #Ecto.Schema.Metadata<:loaded>, id: 1,
 inserted_at: #Ecto.DateTime<2016-04-06T12:57:31Z>,
 product: #Ecto.Association.NotLoaded<association :product is not loaded>,
 product_id: 1, updated_at: #Ecto.DateTime<2016-04-06T12:57:31Z>,
 user: #Ecto.Association.NotLoaded<association :user is not loaded>, user_id: 1}

iex(5)> Nectar.Repo.get(Nectar.User, 1) |> Nectar.User.liked_products |> Nectar.Repo.all
[debug] SELECT u0."id", u0."name", u0."email", u0."encrypted_password", u0."is_admin", u0."inserted_at", u0."updated_at" FROM "users" AS u0 WHERE (u0."id" = $1) [1] OK query=1.2ms
[debug] SELECT DISTINCT p0."id", p0."name", p0."description", p0."available_on", p0."discontinue_on", p0."slug", p0."inserted_at", p0."updated_at" FROM "products" AS p0 INNER JOIN "user_likes" AS u1 ON u1."user_id" IN ($1) WHERE (p0."id" = u1."product_id") [1] OK query=6.6ms
[%Nectar.Product{__meta__: #Ecto.Schema.Metadata<:loaded>,
  available_on: #Ecto.Date<2016-04-06>,
  categories: #Ecto.Association.NotLoaded<association :categories is not loaded>,
  description: "Sample Product for testing without variant",
  discontinue_on: nil, id: 1, inserted_at: #Ecto.DateTime<2016-04-06T12:49:29Z>,
  liked_by: #Ecto.Association.NotLoaded<association :liked_by is not loaded>,
  likes: #Ecto.Association.NotLoaded<association :likes is not loaded>,
  master: #Ecto.Association.NotLoaded<association :master is not loaded>,
  name: "Sample Product",
  option_types: #Ecto.Association.NotLoaded<association :option_types is not loaded>,
  product_categories: #Ecto.Association.NotLoaded<association :product_categories is not loaded>,
  product_option_types: #Ecto.Association.NotLoaded<association :product_option_types is not loaded>,
  slug: "sample-product", updated_at: #Ecto.DateTime<2016-04-06T12:49:29Z>,
  variants: #Ecto.Association.NotLoaded<association :variants is not loaded>}]
{% endraw %}
```

Voila!, we can now save and retreive records to a relation we defined outside nectar from nectar models without actually modifying nectar code.

__VIEW LAYER__: Now that we can save the user likes, we should probably add an interface for the user to like them as well. Which leads us to the first shortcoming, in our current approach, we can replace existing views but right now we don't have anything for adding to an existing view(Please leave us a note here if you know of a clean & performant method to do this). We also suspect most of us will end up overriding the existing views to something more custom then updating it piecemeal via extensions but i digress. For now let's have a page where we list all the products and user can mark them as liked or unlike the previously liked ones.

__controller__

```elixir
defmodule FavoriteProducts.FavoriteController do
  use FavoriteProducts.Web, :controller
  use Guardian.Phoenix.Controller

  alias Nectar.Repo
  alias Nectar.User
  alias Nectar.Product

  alias FavoriteProducts.UserLike
  alias Nectar.Router.Helpers, as: NectarRoutes

  plug Guardian.Plug.EnsureAuthenticated, handler: Nectar.Auth.HandleUnauthenticated

  def index(conn, _params, current_user, _claims) do
    liked_products = Repo.all(User.liked_products(current_user))
    all_products = Repo.all(Product)
    render conn, "index.html", liked_products: liked_products, all_products: all_products
  end

  def create(conn, %{"product_id" => product_id}, current_user, _claims) do
    changeset = UserLike.changeset(%UserLike{}, %{"product_id" => product_id, "user_id" => current_user.id})
    case Repo.insert(changeset) do
      {:ok, _product} ->
        conn
        |> put_flash(:info, "Product favorited successfully.")
        |> redirect(to: NectarRoutes.favorite_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:info, "Product favorited failed #{changeset.errors[:product_id]}")
        |> redirect(to: NectarRoutes.favorite_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => id}, current_user, _claims) do
    user_like = Repo.one(from u in UserLike, where: (u.product_id == ^id and u.user_id == ^current_user.id))

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user_like)

    conn
    |> put_flash(:info, "Product removed from favorites successfully.")
    |> redirect(to: NectarRoutes.favorite_path(conn, :index))
  end
end
```

Notice how we use the Nectar.Repo itself instead of using the FavoriteProducts.Repo, infact beside migration, we won't be utilizing or starting the FavoriteProducts.Repo, which will help us keep the number of connections open to database limited via only the Nectar.Repo

__the view file: index.html.eex__

```elixir
<h2>Listing favorites</h2>

<table class="table">
  <thead>
    <tr>
      <th>Product</th>

      <th></th>
    </tr>
  </thead>
  <tbody>
    <%= for product <- @liked_products do %>
        <tr>
          <td><%= product.name %></td>

          <td class="text-right">
            <%= link "Delete", to: NectarRoutes.favorite_path(@conn, :delete, product), method: :delete, data: [confirm: "Are you sure?"], class: "btn btn-danger btn-xs" %>
          </td>
        </tr>
    <% end %>
  </tbody>
</table>

<h2>Listing Products</h2>

<table class="table">
  <thead>
    <tr>
      <th>Product</th>

      <th></th>
    </tr>
  </thead>
  <tbody>
    <%= for product <- @all_products do %>
        <tr>
          <td><%= product.name %></td>

          <td class="text-right">
            <%= link "Mark", to: NectarRoutes.favorite_path(@conn, :create, %{"product_id" => product.id}), method: :post, class: "btn" %>
          </td>
        </tr>
    <% end %>
  </tbody>
</table>
```

In both of the files we refer to routes via NectarRoutes alias instead of favorite products.
To add the route from nectar, update nectar_extension.ex with the following code:

```elixir
defp do_install("router") do
  quote do
    define_route do
      scope "/", FavoriteProducts do
        # Do not forget to add the pipelines request should go through
        pipe_through [:browser, :browser_auth]
        resources "/favorites", FavoriteController, only: [:index, :create, :delete]
      end
    end
  end
end
```

and add to install.ex the call:

```elixir
defmodule ExtensionsManager.Router do
  use ExtensionsManager.RouterExtension
  use FavoriteProducts.NectarExtension, install: "router"
end
```

Now we can see the added routes from nectar

```bash
mix phoenix.routes | grep 'favorites'
favorite_path  GET     /favorites        FavoriteProducts.FavoriteController :index
favorite_path  POST    /favorites        FavoriteProducts.FavoriteController :create
favorite_path  DELETE  /favorites/:id    FavoriteProducts.FavoriteController :delete
```

So far so good, we have modified and added routes and controller to nectar's router. Time to see our handiwork in action, start the server from nectar application with:

```bash
mix phoenix.server
```

and visit 127.0.0.1:4000/favorite and click on mark to like a product.

![Missing Layout](assets/images/before_layout.png){: .center-image }


But things don't seem right do they, our Nectar layout has been replaced with the default one used by phoenix. let's rectify that.

update layout_view.ex as:

```elixir
defmodule FavoriteProducts.LayoutView do
  use FavoriteProducts.Web, :view
  defdelegate render(template, assigns), to: Nectar.LayoutView
end
```

and recompile and restart the server

```bash
mix clean && mix compile && mix phoenix.server
```

On our next visit:

![Layout Present](assets/images/after_layout.png){: .center-image }

Much better.

> __Note__: When we need to change the extension code while running the server we will have to recompile by stopping the server. We don't have anything in Nectar right now for monitor all extensions file and do an auto code reload.


#Testing#
We are almost done now. To ensure that we know when things break we should add a few tests. For that we need to make sure that nectar migrations are run before running the migrations for favorite products and we need the nectar repo running as well.

for the former we could update the test_helper.ex with:

```elixir
ExUnit.start

Mix.Task.run "ecto.create", ~w(-r FavoriteProducts.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Nectar.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r FavoriteProducts.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(FavoriteProducts.Repo)
```

But things are not so smooth this time. Which brings us to what we think is the ultimate downfall of this approach:

### An Untestable soution ###

Ideally, running ```mix test``` should work and we should see our test running green, unfortunately this requires nectar to be compiled before running the tests, which is impossible since nectar depends upon the extension_manager to be compiled which depends upon all the extensions to be compiled. Also We used nectar's repo for running all the code well that works because we were running our server through nectar and the repo was started in Nectar's Supervision tree. Which again add an implicit requirement Nectar is available and ready to be started during test time or that we can replace it with FavoriteProducts.Repo if MIX_ENV=test, which is a hole we would rather avoid right now.

This seems like the end of the road for this approach. Where we are failing right now is making nectar available to extensions as a dependency at compile time and in turn test time. So that they can run independently. Let's try that in our second approach and reverse the dependency order [link to second approach]().

Credits
-------

[![vinsol.com: Ruby on Rails, iOS and Android developers](http://vinsol.com/vin_logo.png "Ruby on Rails, iOS and Android developers")](http://vinsol.com)

Copyright (c) 2016 [vinsol.com](http://vinsol.com "Ruby on Rails, iOS and Android developers"), released under the New MIT License
