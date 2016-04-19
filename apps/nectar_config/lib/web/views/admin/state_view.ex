defmodule Nectar.Admin.StateView do
  use Nectar.Web, :view

  def render("state.json", %{state: state}) do
    %{id: state.id, name: state.name, abbr: state.abbr}
  end

  def render("error.json", %{changeset: changeset}) do
    render_changeset_error_json(changeset)
  end

end
