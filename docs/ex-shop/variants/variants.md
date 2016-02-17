- mix phoenix.gen.html Admin.Variant variants sku:string weight:decimal height:decimal width:decimal depth:decimal discontinue_on:datetime cost_price:decimal image:string --no-model
- Add nested routes for variants
- Avoid Blocker of not finding variant_path as scoped under admin but generators add variant_path :(
  - compilation fails and mix tasks are blocked too :(
    - add a dummy_path resource "/variants", Admin.VariantController and fix views, controllers one-by-one
- Added plugs to load product/variant and use conn.assigns to access at later stage

- Wasted one hour figuring exception, was due to <%= IO.inspect @get_option_types %> in template :(
  [{"T Shirt Size", 1}, {"Shirt Size", 2}, {"1", 3}]
  [info] Sent 500 in 32ms
  [error] #PID<0.911.0> running ExShop.Endpoint terminated
  Server: localhost:4000 (http)
  Request: GET /admin/products/1/edit
  ** (exit) an exception was raised:
      ** (ArgumentError) lists in Phoenix.HTML and templates may only contain integers, binaries or other lists, got invalid entry: {"T Shirt Size", 1}
          (phoenix_html) lib/phoenix_html/safe.ex:55: Phoenix.HTML.Safe.List.to_iodata/1
          (phoenix_html) lib/phoenix_html/safe.ex:29: Phoenix.HTML.Safe.List.to_iodata/1
          (ex_shop) web/templates/admin/product/edit.html.eex:3: ExShop.Admin.ProductView."edit.html"/1
          (ex_shop) web/templates/layout/app.html.eex:26: ExShop.LayoutView."app.html"/1
          (phoenix) lib/phoenix/view.ex:344: Phoenix.View.render_to_iodata/3
          (phoenix) lib/phoenix/controller.ex:633: Phoenix.Controller.do_render/4
          (ex_shop) web/controllers/admin/product_controller.ex:1: ExShop.Admin.ProductController.action/2
          (ex_shop) web/controllers/admin/product_controller.ex:1: ExShop.Admin.ProductController.phoenix_controller_pipeline/2
          (ex_shop) lib/phoenix/router.ex:261: ExShop.Router.dispatch/2
          (ex_shop) web/router.ex:1: ExShop.Router.do_call/2
          (ex_shop) lib/ex_shop/endpoint.ex:1: ExShop.Endpoint.phoenix_pipeline/1
          (ex_shop) lib/plug/debugger.ex:93: ExShop.Endpoint."call (overridable 3)"/2
          (ex_shop) lib/phoenix/endpoint/render_errors.ex:34: ExShop.Endpoint.call/2
          (plug) lib/plug/adapters/cowboy/handler.ex:15: Plug.Adapters.Cowboy.Handler.upgrade/4
          (cowboy) src/cowboy_protocol.erl:442: :cowboy_protocol.execute/4

          - Below exception gets raised when uploading images using arc_ecto from Variant Module but working from Product Module
            - Reason is image being casted in optional or required parameters for model
            - Hard to figure from error :( .. It was working for Product Model so comparison helped
            [info] POST /admin/products/1/variants/3
            [debug] SELECT u0."id", u0."name", u0."email", u0."encrypted_password", u0."is_admin", u0."inserted_at", u0."updated_at" FROM "users" AS u0 WHERE (u0."id" = $1) [1] OK query=0.8ms
            [debug] Processing by ExShop.Admin.VariantController.update/2
              Parameters: %{"_csrf_token" => "YSYcCCp+MhMkZV0BewMrS2ojcBwhEAAA4EMjoOKGRQ9B9FyrEFHOoQ==", "_method" => "put", "_utf8" => "✓", "id" => "3", "product_id" => "1", "variant" => %{"cost_price" => "1", "discontinue_on" => %{"day" => "1", "month" => "1", "year" => "2011"}, "height" => "", "image" => %Plug.Upload{content_type: "image/jpeg", filename: "riding_spree_1.jpg", path: "/var/folders/r2/yjjd25kj3pq5x32wh09bswxr0000gn/T//plug-1455/multipart-649279-185837-2"}, "sku" => "", "weight" => "", "width" => ""}}
              Pipelines: [:browser, :admin_browser_auth]
            [debug] SELECT p0."id", p0."name", p0."description", p0."available_on", p0."discontinue_on", p0."slug", p0."inserted_at", p0."updated_at" FROM "products" AS p0 WHERE (p0."id" = $1) [1] OK query=0.5ms
            [debug] SELECT v0."id", v0."is_master", v0."sku", v0."weight", v0."height", v0."width", v0."depth", v0."discontinue_on", v0."cost_price", v0."cost_currency", v0."image", v0."product_id", v0."inserted_at", v0."updated_at" FROM "variants" AS v0 WHERE ((v0."id" = $1) AND (v0."product_id" = $2)) [3, 1] OK query=0.5ms
            [debug] SELECT p0."id", p0."name", p0."description", p0."available_on", p0."discontinue_on", p0."slug", p0."inserted_at", p0."updated_at" FROM "products" AS p0 WHERE (p0."id" IN ($1)) [1] OK query=0.5ms
            [error] Task #PID<0.567.0> started from #PID<0.562.0> terminating
            ** (UndefinedFunctionError) undefined function nil.id/0 (module nil is not available)
                nil.id()
                (ex_shop) ExShop.VariantImage.storage_dir/2
                lib/arc/storage/local.ex:3: Arc.Storage.Local.put/3
                (elixir) lib/task/supervised.ex:89: Task.Supervised.do_apply/2
                (elixir) lib/task/supervised.ex:40: Task.Supervised.reply/5
                (stdlib) proc_lib.erl:240: :proc_lib.init_p_do_apply/3
            Function: #Function<2.66522551/0 in Arc.Actions.Store.async_put_version/3>
                Args: []
            [error] Ranch protocol #PID<0.562.0> (:cowboy_protocol) of listener ExShop.Endpoint.HTTP terminated
            ** (exit) an exception was raised:
                ** (UndefinedFunctionError) undefined function nil.id/0
                    nil.id()
                    (ex_shop) ExShop.VariantImage.storage_dir/2
                    lib/arc/storage/local.ex:3: Arc.Storage.Local.put/3
                    (elixir) lib/task/supervised.ex:89: Task.Supervised.do_apply/2
                    (elixir) lib/task/supervised.ex:40: Task.Supervised.reply/5
                    (stdlib) proc_lib.erl:240: :proc_lib.init_p_do_apply/3


- mix phoenix.gen.model VariantOptionValue variant_option_values variant_id:references:variants option_value_id:references:option_values

- Missing `do` raises below exception :P 
== Compilation error on file web/views/admin/variant_view.ex ==
** (EEx.SyntaxError) web/templates/admin/variant/show.html.eex:23: unexpected token ' end '
