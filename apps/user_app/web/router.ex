defmodule UserApp.Router do
  use UserApp.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", UserApp do
    pipe_through :browser # Use the default browser stack
  end

  # act as final catch
  forward "/", Nectar.Router

  # Other scopes may use custom stacks.
  # scope "/api", UserApp do
  #   pipe_through :api
  # end
end
