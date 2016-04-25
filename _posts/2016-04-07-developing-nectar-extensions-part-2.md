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

>
The post belongs to _NectarCommerce and Extension Framework Awareness_ Series
>
1. _[NectarCommerce Vision](http://vinsol.com/blog/2016/04/08/nectarcommerce-vision/)_
1. _[Extension Framework Game Plan](http://vinsol.com/blog/2016/04/12/extension-framework-game-plan/)_
1. _[Introduction to Metaprogramming](http://vinsol.com/blog/2016/04/14/introduction-to-metaprogramming/)_
1. _[Ecto Model Schema Extension](http://vinsol.com/blog/2016/04/15/ecto-model-schema-extension/)_
1. Ecto Model Support Functions Extension
1. Phoenix Router Extension
1. Phoenix View Extension
1. Running Multiple Elixir Apps Together
1. Extension Approach Explained
1. **Developer Experience and Workflow developing Favorite Product Extension**
1. Developer Experience and Workflow testing Favorite Product Extension

Developing Nectar Extensions Part 2
=============

### Where we left off ###

In our [previous approach](), we tried to compile extensions and then based on it compile a version of nectar, which had the serious limitation of Nectar was unavailable for testing.

What we need is that Nectar is available and compiled while developing extensions and if an extension is added it should recompile itself to include the new extensions.
We have modified Nectar for this approach to seek for extensions and used a custom compiler step(A story for another time) to mark files for recompilation. Let's get started and see if we can scale the testing barrier.

Note: Most(read all) of the code for the extension is same. You can probably skim through it if you have gone through the previous post. Copied, pasted and modified with changes highlighted here for posterity.

### A layered guide to nectar extensions ###

__Setup__: Create a new phoenix application to hold the favorite products application.
in your shell run inside the umbrella/apps folder:

<script src="https://gist.github.com/nimish-mehta/994e51defad0787eb88e6611219066fb.js?file=new_phoenix_application.bash"></script>


We could have gone with a regular mix application, but phoenix/ecto will come in handy in this case, since we want to have views to display stuff and a model to store data.

While we are at it let's configure our dev.exs to use the same db as nectar, we could write some code and share the db settings between nectar and our extensions see: link to running multiple phoenix application together for more details. But now for simplicity's sake we are  just copying the settings from nectar to get started.

<script src="https://gist.github.com/nimish-mehta/49dcc6c0bcf6123f536ccc13220bf7ea.js"></script>

We need to let the extension manager know that this application is an extension for nectar.
Update the dependencies in extension\_manager/mix.exs with the favorite_products dependency.

<script src="https://gist.github.com/nimish-mehta/418685331be5beb327c2890bc2257b0f.js"></script>

And now for the big differentiator, we will add nectar as dependency of the favorite_products extension, effectively ensuring it is compiled before the extension.

<script src="https://gist.github.com/nimish-mehta/44fba8f62bec2d95df2c5e911d3ec081.js"></script>

__MODEL LAYER__: We want a nectar user to have some products to like and a way to remember them in short a join table and with two associations let's generate them:

<script src="https://gist.github.com/nimish-mehta/994e51defad0787eb88e6611219066fb.js?file=model_gen.bash"></script>


Now to point to correct nectar models. Open up the source and change the associations to from favorite products model to nectar models. In the end we have a schema like:

<script src="https://gist.github.com/nimish-mehta/c6977aee042c259dc756846b20f0f476.js"></script>


>__Fun Fact__: Since we are depending upon Nectar now we can use ```Nectar.Web, :model``` instead of ```FavoriteProducts.Web, :model``` in user_like.ex and make our extensions available for extension.

Of, course this is only the extension view of this relationship, We want the nectar user to be aware of this relationship and most important of all, we should be able to do something like ```Nectar.User.liked_products(user)``` to fetch the liked products of the user.

Calling our handy macros to perform the dark art of compile time code injection. Let's create the nectar\_extension.ex file in favorite_products/lib/ directory and place this code there:

<script src="https://gist.github.com/nimish-mehta/c723dd21b0251d19b34c8e2f646e2398.js"></script>

Don't forget to update the install file in extensions_manager.

<script src="https://gist.github.com/nimish-mehta/116e7e7d0d3b03593e5184dff50c2a74.js"></script>

Now we have a user that can like products and product from which we can query what users liked it. Time to play.

From the root of umbrella, run the following to start the shell:

<script src="https://gist.github.com/nimish-mehta/f307d5a6c328e317e93460959bec0a3f.js"></script>

This should trigger another round of compilation. Ultimately loading the extension code into nectar. Lets see if we were successful. But before doing that we should migrate the database.

<script src="https://gist.github.com/nimish-mehta/994e51defad0787eb88e6611219066fb.js?file=migrate.bash"></script>

<script src="https://gist.github.com/nimish-mehta/0906cc2cf4929508e3ee75bb6cf1c8e1.js"></script>

Voila, we can now save and retrieve records to a relation we defined outside nectar from nectar models.

__VIEW LAYER__: Now that we can save the user likes, we should probably add an interface for the user to like them as well. Which leads us to the first shortcoming in our current approach, we can replace existing views but right now we don't have anything for adding to an existing view(Please leave us a note here if you know of a clean performant approach to do this). Meanwhile we expect most people will end up overriding the existing views to something more custom then updating it piecemeal but i digress. For now let's have a page where we list all the products and user can mark them as liked or unlike the previously liked ones.

__controller__

<script src="https://gist.github.com/nimish-mehta/529ae0c19711ddc6cdd43ae3232a1a4d.js"></script>

Notice how we use the Nectar.Repo itself instead of using the FavoriteProducts.Repo, infact beside migration, we won't be utilizing or starting the FavoriteProducts.Repo, which will help us keep the number of connections open to database limited via only the Nectar.Repo

__index.html.eex__

<script src="https://gist.github.com/nimish-mehta/6721beb8eaa06859dbffcef48e99231a.js"></script>

In both of the files we refer to routes via NectarRoutes alias instead of favorite products. To get the assets from nectar add nectar/web/static to the brunch config's watched folders:

<script src="https://gist.github.com/nimish-mehta/38bbd3ee540f680aa5d0e55dc27f0c98.js?file=brunch_config.js"></script>

and in __app.js__, initialize the nectar code:

<script src="https://gist.github.com/nimish-mehta/38bbd3ee540f680aa5d0e55dc27f0c98.js?file=app.js"></script>

Finally for adding the route to nectar, update nectar_extension.ex with the following code:

<script src="https://gist.github.com/nimish-mehta/b58e21723a335263e9efcd82b104d100.js"></script>

And add to install.ex the call:

<script src="https://gist.github.com/nimish-mehta/db7883f628837e7ebca5a1945c4d1bfe.js"></script>

Now we can see the added routes

<script src="https://gist.github.com/nimish-mehta/994e51defad0787eb88e6611219066fb.js?file=route.bash"></script>

let's update the layout as well:

<script src="https://gist.github.com/nimish-mehta/ceb97b1c0539f94d2a4bbf95b202a861.js"></script>


##Starting the server to preview the code##

In the previous version we were directly running the nectar server, However since we are essentially working from ground up. Let us make another change and add a forward from favorite_products to nectar.

In favorite_products/web/router.ex:

<script src="https://gist.github.com/nimish-mehta/8a394f1c876b9fb6f90f43f2b522b4c2.js"></script>

All the usual caveats for forwards apply here. Before doing so please ensure that nectar is added to list of applications in favorite_products.ex.

>__Note__: We have disabled the supervisor for Nectar.Endpoint to specifically allow this and suggest all the extensions do this as well once development is complete. More on this later but suffice to say two endpoints cannot start at and we are now running nectar along-with favorite_products extension.

Now we can run our ```mix phoenix.server``` and go about marking our favorites with nectar layout and all.

![Layout Present](assets/images/after_layout.png){: .center-image }

##Testing##
We are almost done now. To ensure that we know when things break we should add a few tests
of-course, we need to make sure that nectar migrations are run before running the migrations for favorite products and we need the nectar repo running as well.

for the former let's update the test_helper.ex with:

<script src="https://gist.github.com/nimish-mehta/795a1eacd54f876f774d3d91abcc8fb3.js"></script>


__And now to write the tests, this one doesn't end like the previous one.__

The tests for code injection:

Create a new test file tests/model/user_test.ex:

<script src="https://gist.github.com/nimish-mehta/1cac0db66c6140e7b72474198b99e193.js?file=test.ex"></script>

We can test for user_like just like any other ecto model. Let's skip that for now.

Running Them:

<script src="https://gist.github.com/nimish-mehta/1cac0db66c6140e7b72474198b99e193.js?file=result.bash"></script>

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

We can now see developing extensions is not very different from building our store with custom functionality based on nectar. You Start with your store and extract out the functionality into self contained applications and load them back as extensions into nectar.


>
_Our aim with these posts is to start a dialog with the Elixir community on validity and technical soundness of our approach. We would really appreciate your feedback and reviews, and any ideas/suggestions/pull requests for improvements to our current implementation or entirely different and better way to do things to achieve the goals we have set out for NectarCommerce._

_Enjoy the Elixir potion !!_
