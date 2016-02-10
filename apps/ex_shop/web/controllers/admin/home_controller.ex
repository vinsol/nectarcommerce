defmodule ExShop.Admin.HomeController do
  use ExShop.Web, :admin_controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

end
