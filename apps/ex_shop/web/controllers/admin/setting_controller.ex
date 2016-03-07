defmodule ExShop.Admin.SettingController do
  use ExShop.Web, :admin_controller

  plug Guardian.Plug.EnsureAuthenticated, handler: ExShop.Auth.HandleUnauthenticated, key: :admin

  alias ExShop.Setting

  def edit(conn, %{"id" => slug}) do
    setting  = Repo.get_by!(ExShop.Setting, slug: slug)
    changeset = Setting.changeset(setting)
    render(conn, "edit.html", setting: setting, changeset: changeset)
  end

  def update(conn, %{"id" => slug, "setting" => setting_params}) do
    setting = Repo.get_by!(ExShop.Setting, slug: slug)
    changeset = Setting.changeset(setting, setting_params)
    case Repo.update(changeset) do
      {:ok, setting} ->
        conn
        |> put_flash(:info, "Setting updated successfully.")
        |> render("edit.html", setting: setting, changeset: changeset)
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Something went wrong. Please try again.")
        |> render("edit.html", setting: setting, changeset: changeset)
    end
  end

end
