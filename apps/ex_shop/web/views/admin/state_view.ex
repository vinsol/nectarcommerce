defmodule ExShop.Admin.StateView do
	use ExShop.Web, :view
  def render("state.json", %{state: state}) do
    %{id: state.id, name: state.name, abbr: state.abbr}
  end

  def render("error.json", %{changeset: changeset}) do
    errors = Enum.map(changeset.errors, fn {field, details} ->
      %{
        field: field,
        detail: render_detail(details)
       }
    end)
    %{errors: errors}
  end

  def render_detail({message, values}) do
    Enum.reduce values, message, fn {k, v}, acc ->
      String.replace(acc, "%{#{k}}", to_string(v))
    end
  end

  def render_detail(message) do
    message
  end
end
