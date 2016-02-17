defmodule ExShop.Admin.OptionTypeView do
  use ExShop.Web, :view

  alias ExShop.OptionType
  alias ExShop.OptionValue

  def link_to_option_values_fields do
    changeset = OptionType.changeset(%OptionType{option_values: [%OptionValue{}]})
    form = Phoenix.HTML.FormData.to_form(changeset, [])
    fields = render_to_string(__MODULE__, "option_values.html", f: form)
    link "New Option Value", to: "#", "data-template": fields, id: "add_option_value"
  end
end
