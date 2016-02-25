defmodule ExShop.Admin.StateView do
  use ExShop.Web, :view
  def render("state.json", %{state: state}) do
    %{id: state.id, name: state.name, abbr: state.abbr}
  end
end
