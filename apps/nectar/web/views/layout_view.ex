defmodule Nectar.LayoutView do
  use Nectar.Web, :view

  def js_view_name(view_module, view_template) do
    view_module_name(view_module) <> "." <> view_template_name(view_template)
  end

  defp view_module_name(module_name) do
    module_name
    |> Phoenix.Naming.resource_name
    |> Phoenix.Naming.camelize
  end

  defp view_template_name(template_name) do
    String.replace_suffix(template_name, ".html", "")
  end

end
