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

>
_Our aim with these posts is to start a dialog with the Elixir community on validity and technical soundness of our approach. We would really appreciate your feedback and reviews, and any ideas/suggestions/pull requests for improvements to our current implementation or entirely different and better way to do things to achieve the goals we have set out for NectarCommerce._

_Enjoy the Elixir potion !!_

