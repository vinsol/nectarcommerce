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

- mix phoenix.gen.model ProductOptionType product_option_types product_id:references:products option_type_id:references:option_types

- http://stackoverflow.com/questions/33127960/ecto-has-many-through-in-form
  - Unfortunately Ecto 1.0 does not support many to many. It means you will need to receive the IDs and manually build the intermediate association for each group you are associating to the user. We hope to make this easier in future releases.
  - https://github.com/elixir-lang/ecto/pull/1177/files

- alias ExShop.Repo; alias ExShop.Product; alias ExShop.OptionType; alias ExShop.ProductOptionType
- p = Repo.get(Product, 1) |> Repo.preload([:master, :product_option_types])
- o = Repo.get(OptionType, 1)
- c = Product.create_changeset(%Product{}, %{"master" => %{"cost_price" => 1}, "product_option_types" => [%{"product_id": p.id, "option_type_id": o.id}]})
  - As product_option_types is a has_many association, add the Array []

  - has_many :option_types, through: [:product_option_types, :option_type]

  - alias ExShop.Repo; alias ExShop.Product; alias ExShop.Variant; alias ExShop.OptionType; alias ExShop.ProductOptionType
  - a = Repo.get(Product, 1)

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
