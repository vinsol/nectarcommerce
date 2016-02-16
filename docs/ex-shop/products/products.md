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
