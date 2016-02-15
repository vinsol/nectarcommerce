- mix phoenix.gen.model Product products name:string description:text available_on:datetime discontinue_on:datetime
- mix phoenix.gen.model Variant variants is_master:boolean sku:string weight:integer height:integer width:integer depth:integer discontinue_on:datetime cost_price:decimal cost_currency:string product_id:references:products
- mix phoenix.gen.html Admin.Product products name:string description:text available_on:datetime discontinue_on:datetime --no-model
- ** (CompileError) web/templates/admin/product/edit.html.eex:4: undefined function product_path/3

- alias ExShop.Repo; alias ExShop.Product
- b = Product.create_changeset(%Product{}, %{"name" => "1", "description" => "1", "master" => %{"cost_price" => 1}})
- https://hexdocs.pm/ecto/Ecto.Changeset.html#put_change/3
- https://hexdocs.pm/ecto/Ecto.Changeset.html#cast/4
