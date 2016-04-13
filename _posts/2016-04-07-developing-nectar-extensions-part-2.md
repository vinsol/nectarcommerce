---
layout: post
cover: 'assets/images/general-cover-3.jpg'
title: Developing Nectar Extensions Part 2
tags: docs
subclass: 'post tag-docs'
categories: 'elixir'
author: 'Nimish'
navigation: true
logo: 'assets/images/nectar-cart.png'
---

### Where we left off ###

In our [previous approach](), we tried to compile extensions and then based on it compile a version of nectar, which had the serious limitation of Nectar was unavailable for testing.

What we need is that Nectar is available and compiled while developing extensions and if an extension is added it should recompile itself to include the new extensions.
We have modified Nectar for this approach to seek for extensions and used a custom compiler step(A story for another time) to mark files for recompilation. Let's get started and see if we can scale the testing barrier.

Note: Most(read all) of the code for the extension is same. You can probably skim through it if you have gone through the previous post. Copied, pasted and modified with changes highlighted here for posterity.

### A layered guide to nectar extensions ###

__Setup__: Create a new phoenix application to hold the favorite products application.
in your shell run inside the umbrella/apps folder:

```bash
mix phoenix.new favorite_products
```

We could have gone with a regular mix application, but phoenix/ecto will come in handy in this case, since we want to have views to display stuff and a model to store data.

While we are at it let's configure our dev.exs to use the same db as nectar, we could write some code and share the db settings between nectar and our extensions see: link to running multiple phoenix application together for more details. But now for simplicity's sake we are  just copying the settings from nectar to get started.

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

And now for the big differentiator, we will add nectar as dependency of the favorite_products extension, effectively ensuring it is compiled before the extension.

```elixir
defp deps do
  [{:phoenix, "~> 1.1.4"},
   {:postgrex, ">= 0.0.0"},
   {:phoenix_ecto, "~> 2.0"},
   {:phoenix_html, "~> 2.4"},
   {:phoenix_live_reload, "~> 1.0", only: :dev},
   {:gettext, "~> 0.9"},
   {:cowboy, "~> 1.0"}, {:nectar, in_umbrella: true}]
end
```

__MODEL LAYER__: We want a nectar user to have some products to like and a way to remember them in short a join table and with two associations let's generate them:

```bash
cd favorite_products
mix phoenix.gen.model UserLike user_like user_id:references:users product_id:references:products
```

Now to point to correct nectar models. Open up the source and change the associations to from favorite products model to nectar models. In the end we have a schema like:

```elixir
  schema "user_likes" do
    belongs_to :user, Nectar.User
    belongs_to :product, Nectar.Product

    timestamps
  end
```

>__Fun Fact__: Since we are depending upon Nectar now we can use ```Nectar.Web, :model``` instead of ```FavoriteProducts.Web, :model``` in user_like.ex and make our extensions available for extension.

Of, course this is only the extension view of this relationship, We want the nectar user to be aware of this relationship and most important of all, we should be able to do something like

```elixir
Nectar.User.liked_products(user) # fetches the products liked by the user
```

Calling our handy macros to perform the dark art of compile time code injection. Let's create the nectar\_extension.ex file in favorite_products/lib/ directory and place this code there:

```elixir
defmodule FavoriteProducts.NectarExtension do
  defmacro __using__([install: install_type]) do
    do_install(install_type)
  end
  defp do_install("products") do
    quote do
      ## In Phoenix App Model Schema definition, join association is defined first and then through association
      ## Please note the reverse order here as while collecting, it gets collected in the reverse order.
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

Now we have a user that can like products and product from which we can query what users liked it. Time to play.

From the root of umbrella, run:

```bash
mix compile
```

Move to the folder for your extension and run:

```bash
iex -S mix
```

This should trigger another round of compilation. Ultimately loading the extension code into nectar. Lets see if we were successful. But before doing anything we should migrate the database.

```bash
mix ecto.migrate -r FavoriteProducts.Repo
```

{% raw %}
```elixir
# added our association in user
iex(1)> Nectar.User.__schema__(:associations)
[:orders, :user_addresses, :addresses, :likes, :liked_products]
# added our association in product
iex(2)> Nectar.Product.__schema__(:associations)
[:master, :variants, :product_option_types, :option_types, :product_categories,
 :categories, :likes, :liked_by]
# Insertion and queries work as well.
iex(3)> changeset = FavoriteProducts.UserLike.changeset(%FavoriteProducts.UserLike{}, %{user_id: 1, product_id: 1})
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
```
{% endraw %}

Voila, we can now save and retrieve records to a relation we defined outside nectar from nectar models.

__VIEW LAYER__: Now that we can save the user likes, we should probably add an interface for the user to like them as well. Which leads us to the first shortcoming in our current approach, we can replace existing views but right now we don't have anything for adding to an existing view(Please leave us a note here if you know of a clean performant approach to do this). Meanwhile we expect most people will end up overriding the existing views to something more custom then updating it piecemeal but i digress. For now let's have a page where we list all the products and user can mark them as liked or unlike the previously liked ones.

controller

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

__index.html.eex__

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

In both of the files we refer to routes via NectarRoutes alias instead of favorite products. To get the assets from nectar add nectar/web/static to the brunch config's watched folders:

```js
paths: {
  watched: [".../nectar/web/static"]
}
```


and in __app.js__, initialize the nectar code:

```js
import nectar from "../../../nectar/web/static/js/app";
nectar.setup();
window.ajax_setup();
```

Finally for adding the route to nectar, update nectar_extension.ex with the following code:

```elixir
defp do_install("router") do
  quote do
    define_route do
      scope "/", FavoriteProducts do
        ## Do not forget to add the pipelines request should go through
        pipe_through [:browser, :browser_auth]
        resources "/favorites", FavoriteController, only: [:index, :create, :delete]
      end
    end
  end
end
```

And add to install.ex the call:

```elixir
defmodule ExtensionsManager.Router do
  use ExtensionsManager.RouterExtension
  use FavoriteProducts.NectarExtension, install: "router"
end
```.

Now we can see the added routes

```bash
mix phoenix.routes | grep 'favorites'
favorite_path  GET     /favorites        FavoriteProducts.FavoriteController :index
favorite_path  POST    /favorites        FavoriteProducts.FavoriteController :create
favorite_path  DELETE  /favorites/:id    FavoriteProducts.FavoriteController :delete
```

let's update the layout as well:

```elixir
defmodule FavoriteProducts.LayoutView do
  use FavoriteProducts.Web, :view
  defdelegate render(template, assigns), to: Nectar.LayoutView
end
```

##Starting the server to preview the code##

In the previous version we were directly running the nectar server, However since we are essentially working from ground up. Let us make another change and add a forward from favorite_products to nectar.

In favorite_products/web/router.ex:

```elixir
forward  "/", Nectar.Router
```

All the usual caveats for forwards apply here. Before doing so ensure that nectar is added to list of applications in favorite_products.ex.

>__Note__: We have disabled the supervisor for Nectar.Endpoint to specifically allow this and suggest all the extensions do this as well once development is complete. More on this later but suffice to say two endpoints cannot start at and we are now running nectar along-with favorite_products extension.

Now we can run our ```mix phoenix.server``` and go about marking our favorites with nectar layout and all.

![Layout Present](assets/images/after_layout.png){: .center-image }

##Testing##
We are almost done now. To ensure that we know when things break we should add a few tests
of-course, we need to make sure that nectar migrations are run before running the migrations for favorite products and we need the nectar repo running as well.

for the former let's update the test_helper.ex with:

```elixir
ExUnit.start

Mix.Task.run "ecto.create", ~w(-r FavoriteProducts.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Nectar.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r FavoriteProducts.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(FavoriteProducts.Repo)
```


__And now to write the tests, this one doesn't end like the previous one.__

The tests for code injection:

Create a new test file tests/model/user_test.ex:

```elixir
defmodule FavoriteProducts.UserTest do
  use FavoriteProducts.ModelCase

  test "added associations to Nectar.User successfully" do
    assert Enum.member?(Nectar.User.__schema__(:associations), :likes)
    assert Enum.member?(Nectar.User.__schema__(:associations), :liked_products)
  end

  test "added methods to Nectar.User" do
    assert Enum.member?(Nectar.User.__info__(:functions), {:liked_products, 1})
  end

  # ... add test cases for liked_products method
end
```

We can test for user_like just like any other ecto model. Let's skip that for now.

Running Them:

```bash
FavoriteProducts.UserTest
  * added methods to Nectar.User (0.5ms)
  * added associations to Nectar.User successfully (0.3ms)


Finished in 0.2 seconds (0.2s on load, 0.00s on tests)
2 tests, 0 failures
```

## Bonus Guide: Creating our user store application ##

We already did this, when we were creating favorite_products extension. A forward to nectar is all it takes. You can create your phoenix application and add a forward to Nectar.Router to run your user application. Some extensions might require to be added in the application list their processes to start in such cases we need to add a dependency here as well. You might want to do that anyway to support **exrm** release properly(See the next section for more details).

## Bonus Guide: Exrm Release ##

You can read more about how to build an exrm release for an umbrella project [here](https://github.com/bitwalker/exrm-umbrella-test). Following the example outlined in the repository, the main app for our case will be the User Store Application. Let's get started and try to build an exrm release:

>Note: We are going to build our release in Dev environment, the only thing that should change for production is the configuration. Some of the options may already be switched off for the production release. See [Phoenix Guides](http://www.phoenixframework.org/docs/advanced-deployment) for how to build production exrm release for phoenix applications.

__Step 1:__
Update deps of umbrella to include exrm and run ```mix deps.get``` to install them.

```elixir
  defp deps do
    [{:exrm, "~> 1.0"},
     {:conform, "~> 2.0"}]
  end
```

__Step 2:__
Run the mix release command. Let's try it with the dev environment for now.

```bash
mix release
```

Let's examine the output and keep on continuing:

```bash
Building release with MIX_ENV=dev.

You have dependencies (direct/transitive) which are not in :applications!
The following apps should to be added to :applications in mix.exs:

        arc                 => arc is missing from nectar
        phoenix_live_reload => phoenix_live_reload is missing from nectar
        guardian            => guardian is missing from nectar
        comeonin            => comeonin is missing from nectar
Continue anyway? Your release may not work as expected if these dependencies are required! [Yn]:Y

You have dependencies (direct/transitive) which are not in :applications!
The following apps should to be added to :applications in mix.exs:

        phoenix_live_reload => phoenix_live_reload is missing from favorite_products

Continue anyway? Your release may not work as expected if these dependencies are required! [Yn]: Y


You have dependencies (direct/transitive) which are not in :applications!
The following apps should to be added to :applications in mix.exs:

        phoenix_live_reload => phoenix_live_reload is missing from extensions_manager

Continue anyway? Your release may not work as expected if these dependencies are required! [Yn]: Y
```

In the end we can see:

```bash
==> The release for user_app-0.0.1 is ready!
==> You can boot a console running your release with `$ rel/user_app/bin/user_app console`
```

Let's try accessing it. running with no args gives us the output:

```bash
Usage: user_app {start|start_boot <file>|foreground|stop|restart|reboot|ping|rpc <m> <f> [<a>]|console|console_clean|console_boot <file>|attach|remote_console|upgrade|escript|command <m> <f> <args>}
```

We need to start the application to access the user_app and nectar, so let' do that. We are using foreground to see the console output, it can be run as a background service. See here

```bash
user_app foreground
```

and we see

{% raw %}
```bash
[info] Application user_app exited: UserApp.start(:normal, []) returned an error: shutdown: failed to start child: UserApp.Endpoint
    ** (EXIT) shutdown: failed to start child: Phoenix.CodeReloader.Server
        ** (EXIT) an exception was raised:
            ** (UndefinedFunctionError) undefined function Mix.Project.config/0 (module Mix.Project is not available)
                Mix.Project.config()
                (phoenix) lib/phoenix/code_reloader/server.ex:32: Phoenix.CodeReloader.Server.init/1
                (stdlib) gen_server.erl:328: :gen_server.init_it/6
                (stdlib) proc_lib.erl:240: :proc_lib.init_p_do_apply/3
{"Kernel pid terminated",application_controller,"{application_start_failure,user_app,{{shutdown,{failed_to_start_child,'Elixir.UserApp.Endpoint',{shutdown,{failed_to_start_child,'Elixir.Phoenix.CodeReloader.Server',{undef,[{'Elixir.Mix.Project',config,[],[]},{'Elixir.Phoenix.CodeReloader.Server',init,1,[{file,\"lib/phoenix/code_reloader/server.ex\"},{line,32}]},{gen_server,init_it,6,[{file,\"gen_server.erl\"},{line,328}]},{proc_lib,init_p_do_apply,3,[{file,\"proc_lib.erl\"},{line,240}]}]}}}}},{'Elixir.UserApp',start,[normal,[]]}}}"}
[1]    3000 user-defined signal 2  ./user_app foreground
```

It seems to be unable to start the endpoint because the code reloader is missing. We can add to the applications, but since it has no reason for belonging in the release. We will comment out the config for now in dev.exs and set code_reload: false in config.exs, doing that and building a new release.


```bash
./user_app foreground
Using /Users/nimish/nectarcommerce/apps/user_app/rel/user_app/releases/0.0.1/user_app.sh
Exec: /Users/nimish/nectarcommerce/apps/user_app/rel/user_app/erts-7.3/bin/erlexec -noshell -noinput +Bd -boot /Users/nimish/nectarcommerce/apps/user_app/rel/user_app/releases/0.0.1/user_app -mode embedded -config /Users/nimish/nectarcommerce/apps/user_app/rel/user_app/running-config/sys.config -boot_var ERTS_LIB_DIR /Users/nimish/nectarcommerce/apps/user_app/rel/user_app/erts-7.3/../lib -env ERL_LIBS /Users/nimish/nectarcommerce/apps/user_app/rel/user_app/lib -pa /Users/nimish/nectarcommerce/apps/user_app/rel/user_app/lib/user_app-0.0.1/consolidated -args_file /Users/nimish/nectarcommerce/apps/user_app/rel/user_app/running-config/vm.args -- foreground
Root: /Users/nimish/nectarcommerce/apps/user_app/rel/user_app
```

It is working. Now to try accessing the server, it fails with connection refused, the server is not starting automatically.

```bash
➜  bin git:(demo/exrm-release) ✗ curl 127.0.0.1:4000
curl: (7) Failed to connect to 127.0.0.1 port 4000: Connection refused
```

Going over the [phoenix endpoint configuration](https://hexdocs.pm/phoenix/Phoenix.Endpoint.html), we need to set server: true in endpoint configuration which is done automatically when running mix phoenix.server, doing that and rebuilding the release.

```bash
nectarcommerce git:(demo/exrm-release) ✗ curl -I 127.0.0.1:4000
HTTP/1.1 500 Internal Server Error
server: Cowboy
date: Wed, 13 Apr 2016 07:23:52 GMT
content-length: 59069
cache-control: max-age=0, private, must-revalidate
x-request-id: 52ia845ci05jqvh45gpmi8r87e0n9ctq
x-frame-options: SAMEORIGIN
x-xss-protection: 1; mode=block
x-content-type-options: nosniff
content-type: text/html; charset=utf-8
```

It's alive! but we are getting 500 error. hopping over to the logs(remember we are running it in the foreground mode)

```bash
[error] #PID<0.1543.0> running UserApp.Endpoint terminated
Server: 127.0.0.1:4000 (http)
Request: HEAD /
** (exit) an exception was raised:
    ** (UndefinedFunctionError) undefined function Guardian.Plug.VerifySession.call/2 (module Guardian.Plug.VerifySession is not available)
        Guardian.Plug.VerifySession.call(%Plug.Conn{adapter: {Plug.Adapters.Cowboy.Conn, :...}, assigns: %{}, before_send: [#Function<1.82290246/1 in Plug.CSRFProtection.call/2>, #Function<5.131212018/1 in Phoenix.Controller.fetch_flash/2>, #Function<0.10189836/1 in Plug.Session.before_send/2>, #Function<1.18936798/1 in Plug.Logger.call/2>], body_params: %{}, cookies: %{}, halted: false, host: "127.0.0.1", method: "GET", owner: #PID<0.1543.0>, params: %{}, path_info: [], peer: {{127, 0, 0, 1}, 51188}, port: 4000, private: %{Nectar.Router => {[], %{}}, UserApp.Router => {[], %{Nectar.Router => []}}, :phoenix_endpoint => UserApp.Endpoint, :phoenix_flash => %{}, :phoenix_format => "html", :phoenix_pipelines => [:browser, :browser_auth, Nectar.Plugs.Cart], :phoenix_route => #Function<154.35267891/1 in Nectar.Router.match_route/4>, :phoenix_router => Nectar.Router, :plug_session => %{}, :plug_session_fetch => :done}, query_params: %{}, query_string: "", remote_ip: {127, 0, 0, 1}, req_cookies: %{}, req_headers: [{"host", "127.0.0.1:4000"}, {"user-agent", "curl/7.43.0"}, {"accept", "*/*"}], request_path: "/", resp_body: nil, resp_cookies: %{}, resp_headers: [{"cache-control", "max-age=0, private, must-revalidate"}, {"x-request-id", "52ia845ci05jqvh45gpmi8r87e0n9ctq"}, {"x-frame-options", "SAMEORIGIN"}, {"x-xss-protection", "1; mode=block"}, {"x-content-type-options", "nosniff"}], scheme: :http, script_name: [], secret_key_base: "YlpnKFOAkqdNvXYDPHKUX8e0EqwK0xXJQdvQbLnAFhyctLLXvO7Yb7emhBM2Slvg", state: :unset, status: nil}, %{})
        (nectar) web/router.ex:12: Nectar.Router.browser_auth/2
        (nectar) web/router.ex:1: Nectar.Router.match_route/4
        (nectar) web/router.ex:1: Nectar.Router.do_call/2
        (phoenix) lib/phoenix/router/route.ex:157: Phoenix.Router.Route.forward/4
        (user_app) lib/phoenix/router.ex:261: UserApp.Router.dispatch/2
        (user_app) web/router.ex:1: UserApp.Router.do_call/2
        (user_app) lib/user_app/endpoint.ex:1: UserApp.Endpoint.phoenix_pipeline/1
        (user_app) lib/plug/debugger.ex:93: UserApp.Endpoint."call (overridable 3)"/2
        (user_app) lib/phoenix/endpoint/render_errors.ex:34: UserApp.Endpoint.call/2
        (plug) lib/plug/adapters/cowboy/handler.ex:15: Plug.Adapters.Cowboy.Handler.upgrade/4
        (cowboy) src/cowboy_protocol.erl:442: :cowboy_protocol.execute/4
```

It fails because guardian is not loaded. This was one of the missing dependencies which were not included in running applications. There were four of them:

1. guardian
2. arc
3. comeonin
4. phoenix_live_reload

Since we have already tackled the last one, let's add the first three in the application list in nectar.

```elixir
  def application do
    [
      mod: {Nectar, []},
      applications: [
        :phoenix, :phoenix_html, :cowboy, :logger, :gettext,
        :phoenix_ecto, :postgrex, :worldly, :yamerl, :commerce_billing, :braintree,
        :ex_aws, :httpoison, :guardian, :comeonin, :arc_ecto, :arc
      ]
    ]
  end
```

and try again.

```
 nectarcommerce git:(demo/exrm-release) ✗ curl -I 127.0.0.1:4000
HTTP/1.1 200 OK
server: Cowboy
date: Wed, 13 Apr 2016 07:36:17 GMT
content-length: 2443
set-cookie: _user_app_key=g3QAAAACbQAAAAtfY3NyZl90b2tlbm0AAAAYNTVSaGpWYUZ4TVRyYXpONkxNekh0Zz09bQAAAA1jdXJyZW50X29yZGVyYQY=--BH33OU-_kWtE-G22OZryITrQJSM=; path=/; HttpOnly
content-type: text/html; charset=utf-8
cache-control: max-age=0, private, must-revalidate
x-request-id: jifoth5lcqrkhtkcuhi425vos3g2rot7
x-frame-options: SAMEORIGIN
x-xss-protection: 1; mode=block
x-content-type-options: nosniff
```

Success. Similarly we can copy over the config for production environment when building our exrm release. Now we can deploy the user app as the main application, See phoenix guides for details on how to configure and build exrm releases for production.

You can always run ``` mix release.clean -- implode ``` to clean up your workspace.



## Suggested Workflow ##

Basically Start with your store and extract out the functionality into self contained modules and load them back as extension.

Credits
-------

[![vinsol.com: Ruby on Rails, iOS and Android developers](http://vinsol.com/vin_logo.png "Ruby on Rails, iOS and Android developers")](http://vinsol.com)

Copyright (c) 2016 [vinsol.com](http://vinsol.com "Ruby on Rails, iOS and Android developers"), released under the New MIT License
