- mix phoenix.gen.model Product products name:string description:text available_on:datetime discontinue_on:datetime
- mix phoenix.gen.model Variant variants is_master:boolean sku:string weight:integer height:integer width:integer depth:integer discontinue_on:datetime cost_price:decimal cost_currency:string product_id:references:products
- mix phoenix.gen.html Admin.Product products name:string description:text available_on:datetime discontinue_on:datetime --no-model
- ** (CompileError) web/templates/admin/product/edit.html.eex:4: undefined function product_path/3

- alias ExShop.Repo; alias ExShop.Product; alias ExShop.Variant; alias ExShop.VariantImage
- b = Product.create_changeset(%Product{}, %{"name" => "1", "description" => "1", "master" => %{"cost_price" => 1}})
- https://hexdocs.pm/ecto/Ecto.Changeset.html#put_change/3
- https://hexdocs.pm/ecto/Ecto.Changeset.html#cast/4

- a = Repo.get(ExShop.Variant, 1)
- VariantImage.urls({a.image, a})
- VariantImage.url({a.image, a}, :thumb)

- http://stackoverflow.com/questions/33127960/ecto-has-many-through-in-form
  - Unfortunately Ecto 1.0 does not support many to many. It means you will need to receive the IDs and manually build the intermediate association for each group you are associating to the user. We hope to make this easier in future releases.
  - https://github.com/elixir-lang/ecto/pull/1177/files

- alias ExShop.Repo; alias ExShop.Product; alias ExShop.OptionType; alias ExShop.ProductOptionType
- p = Repo.get(Product, 1) |> Repo.preload([:master, :product_option_types])
- o = Repo.get(OptionType, 1)
- c = Product.create_changeset(%Product{}, %{"master" => %{"cost_price" => 1}, "product_option_types" => [%{"product_id": p.id, "option_type_id": o.id}]})
  - As product_option_types is a has_many association, add the Array []

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

- has_many :option_types, through: [:product_option_types, :option_type]

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





# References

- https://medium.com/@diamondgfx/writing-a-blog-engine-in-phoenix-part-2-authorization-814c06fa7c0#.jesgbj2do
- http://meatherly.github.io/2015/05/04/phoenixlivelikeawarrior/
- http://stackoverflow.com/questions/32064273/how-to-change-the-parameter-name-using-resources-in-phoenix-framework-router
- http://elixir-lang.org/docs/v1.0/elixir/Enum.html#flat_map/2
- https://stackoverflow.com/questions/33803754/phoenix-ordering-a-query-set
- http://stackoverflow.com/questions/33805309/how-to-show-all-records-of-a-model-in-phoenix-select-field
- http://stackoverflow.com/questions/29313717/inserting-associated-models-in-ecto
- http://blog.tokafish.com/rails-to-phoenix-getting-started-with-ecto/
- https://hexdocs.pm/ecto/Ecto.Changeset.html
- https://gist.github.com/joeellis/8e726d4d8bbb3b92e63e
- http://www.glydergun.com/diving-into-ecto/
- http://stackoverflow.com/questions/31308969/programmatically-preload-has-many-through-in-elixir-ecto
- https://hexdocs.pm/ecto/Ecto.Schema.html
- https://blog.drewolson.org/composable-queries-ecto/
- http://stackoverflow.com/questions/32900114/many-to-many-relationship-in-ecto
- http://stackoverflow.com/questions/30472081/join-two-tables-belong-to-two-database-in-elixir-ecto
