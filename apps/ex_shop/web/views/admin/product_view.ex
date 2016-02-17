defmodule ExShop.Admin.ProductView do
  use ExShop.Web, :view

  alias ExShop.Repo
  alias ExShop.Product
  alias ExShop.ProductOptionType
  alias ExShop.OptionType

  def link_to_product_option_types_fields do
    changeset = Product.changeset(%Product{product_option_types: [%ProductOptionType{}]})
    form = Phoenix.HTML.FormData.to_form(changeset, [])
    get_option_types = Repo.all(OptionType) |> Enum.map(fn(x) -> {x.name, x.id} end)
    fields = render_to_string(__MODULE__, "product_option_types.html", f: form, get_option_types: get_option_types)
    link "Add Option Type", to: "#", "data-template": fields, id: "add_product_option_type"
  end
end
