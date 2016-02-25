defmodule Seed.LoadSettings do
  alias ExShop.Setting
  alias ExShop.Repo

  def seed! do
    create_general_settings
  end

  defp create_general_settings do
    change = Setting.changeset(%Setting{}, %{name: "general", settings: get_settings})
    Repo.insert!(change)
  end

  defp get_settings do
    [
     %{name: "store_name", value: ""},
     %{name: "seo_title", value: ""},
     %{name: "meta_description", value: ""},
     %{name: "meta_keywords", value: ""},
     %{name: "site_url", value: ""},
     %{name: "mail_from_address", value: "demo"},
     %{name: "country_code", value: "IN"}
    ]
  end


end
