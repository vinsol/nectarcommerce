defmodule ExShop.Admin.SettingView do
  use ExShop.Web, :view

  def setting_name(%Phoenix.HTML.Form{data: %ExShop.SettingPair{name: name}}) do
    Phoenix.Naming.humanize(name)
  end
end
