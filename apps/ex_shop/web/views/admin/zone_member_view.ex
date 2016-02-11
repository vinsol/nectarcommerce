defmodule ExShop.Admin.ZoneMemberView do
  use ExShop.Web, :view

  def render("zone_member.json", %{zoneable: zoneable}) do
    %{id: zoneable.id, name: zoneable.name}
  end

  def render("success.json", _) do
    %{success: "ok"}
  end
end
